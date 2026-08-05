defmodule QuranApi.Auth.User do
  @moduledoc """
  Schema for User authentication and authorization.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          email: String.t(),
          password_hash: String.t(),
          role: String.t(),
          status: String.t(),
          first_name: String.t() | nil,
          last_name: String.t() | nil,
          last_login_at: DateTime.t() | nil,
          last_login_ip: String.t() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @roles [:admin, :editor, :readonly]
  @statuses [:active, :inactive, :suspended]

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :password_hash, :string, redact: true
    field :role, Ecto.Enum, values: [:admin, :editor, :readonly], default: :editor
    field :status, Ecto.Enum, values: [:active, :inactive, :suspended], default: :active
    field :first_name, :string
    field :last_name, :string
    field :name, :string, virtual: true
    field :last_login_at, :utc_datetime
    field :last_login_ip, :string

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset for creating a new user.
  """
  @spec registration_changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def registration_changeset(user, attrs) do
    attrs = normalize_name_attrs(attrs)

    user
    |> cast(attrs, [:email, :password, :role, :first_name, :last_name])
    |> validate_required([:email, :password, :role])
    |> validate_email()
    |> validate_password()
    |> put_virtual_name()
    |> validate_role()
    |> put_password_hash()
  end

  @doc """
  Changeset for updating user profile.
  """
  @spec changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def changeset(user, attrs) do
    attrs = normalize_name_attrs(attrs)

    user
    |> cast(attrs, [:email, :first_name, :last_name, :role, :status])
    |> validate_required([:email, :role, :status])
    |> put_virtual_name()
    |> validate_email()
    |> validate_role()
    |> validate_status()
  end

  @doc """
  Changeset for updating password.
  """
  @spec password_changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def password_changeset(user, attrs) do
    user
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_password()
    |> put_password_hash()
  end

  @doc """
  Changeset for updating last login information.
  """
  @spec login_changeset(Ecto.Schema.t(), String.t()) :: Ecto.Changeset.t()
  def login_changeset(user, ip_address) do
    change(user, %{
      last_login_at: DateTime.utc_now() |> DateTime.truncate(:second),
      last_login_ip: ip_address
    })
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email")
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, QuranApi.Repo)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 8, max: 80)
    |> validate_format(:password, ~r/[a-z]/,
      message: "must contain at least one lowercase letter"
    )
    |> validate_format(:password, ~r/[A-Z]/,
      message: "must contain at least one uppercase letter"
    )
    |> validate_format(:password, ~r/[0-9]/, message: "must contain at least one number")
  end

  defp validate_role(changeset) do
    validate_inclusion(changeset, :role, @roles)
  end

  defp validate_status(changeset) do
    validate_inclusion(changeset, :status, @statuses)
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Argon2.hash_pwd_salt(password))

      _ ->
        changeset
    end
  end

  @doc """
  Returns true if user has admin role.
  """
  @spec admin?(t()) :: boolean()
  def admin?(%__MODULE__{role: "admin"}), do: true
  def admin?(_), do: false

  @doc """
  Returns true if user has editor role or higher.
  """
  @spec editor?(t()) :: boolean()
  def editor?(%__MODULE__{role: role}) when role in ["admin", "editor"], do: true
  def editor?(_), do: false

  @doc """
  Returns true if user is active.
  """
  @spec active?(t()) :: boolean()
  def active?(%__MODULE__{status: :active}), do: true
  def active?(_), do: false

  # Helper function to normalize "name" attribute to first_name/last_name
  defp normalize_name_attrs(attrs) do
    # Determine if attrs uses string or atom keys
    use_string_keys = Map.has_key?(attrs, "name") or not Map.has_key?(attrs, :name)

    case Map.get(attrs, :name) || Map.get(attrs, "name") do
      nil ->
        attrs

      name when is_binary(name) ->
        # Split name on first space
        {first_key, last_key} =
          if use_string_keys do
            {"first_name", "last_name"}
          else
            {:first_name, :last_name}
          end

        case String.split(name, " ", parts: 2) do
          [first] ->
            attrs
            |> Map.put(first_key, first)
            |> Map.delete(:name)
            |> Map.delete("name")

          [first, last] ->
            attrs
            |> Map.put(first_key, first)
            |> Map.put(last_key, last)
            |> Map.delete(:name)
            |> Map.delete("name")
        end
    end
  end

  # Helper to set virtual name field from first_name and last_name
  defp put_virtual_name(changeset) do
    first = get_field(changeset, :first_name)
    last = get_field(changeset, :last_name)

    name =
      case {first, last} do
        {nil, nil} -> nil
        {f, nil} -> f
        {nil, l} -> l
        {f, l} -> "#{f} #{l}"
      end

    put_change(changeset, :name, name)
  end
end
