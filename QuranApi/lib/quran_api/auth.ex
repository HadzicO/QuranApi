defmodule QuranApi.Auth do
  @moduledoc """
  The Auth context handles user authentication and authorization.
  """
  import Ecto.Query, warn: false
  alias QuranApi.Repo
  alias QuranApi.Auth.{Guardian, User}

  @doc """
  Gets a single user.
  """
  @spec get_user(integer() | String.t()) :: User.t() | nil
  def get_user(id) when is_binary(id) do
    case Integer.parse(id) do
      {int_id, ""} -> get_user(int_id)
      _ -> nil
    end
  end

  def get_user(id) when is_integer(id) do
    Repo.get(User, id)
  end

  @doc """
  Gets a user by email.
  """
  @spec get_user_by_email(String.t()) :: User.t() | nil
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Lists all users.
  """
  @spec list_users(keyword()) :: [User.t()]
  def list_users(opts \\ []) do
    role = Keyword.get(opts, :role)
    status = Keyword.get(opts, :status)
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 20)

    User
    |> maybe_filter_by_role(role)
    |> maybe_filter_by_status(status)
    |> order_by([u], desc: u.inserted_at)
    |> limit(^per_page)
    |> offset(^((page - 1) * per_page))
    |> Repo.all()
  end

  @doc """
  Creates a user.
  """
  @spec create_user(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def create_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.
  """
  @spec update_user(User.t(), map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates user password.
  """
  @spec update_password(User.t(), map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def update_password(%User{} = user, attrs) do
    user
    |> User.password_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.
  """
  @spec delete_user(User.t()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Authenticates a user with email and password.
  """
  @spec authenticate(String.t(), String.t(), String.t()) ::
          {:ok, User.t(), map()} | {:error, :invalid_credentials | :inactive_user | :suspended}
  def authenticate(email, password, ip_address \\ "unknown") do
    case get_user_by_email(email) do
      nil ->
        Argon2.no_user_verify()
        {:error, :invalid_credentials}

      user ->
        authenticate_user(user, password, ip_address)
    end
  end

  defp authenticate_user(user, password, ip_address) do
    if Argon2.verify_pass(password, user.password_hash) do
      handle_valid_credentials(user, ip_address)
    else
      {:error, :invalid_credentials}
    end
  end

  @dialyzer {:nowarn_function, handle_valid_credentials: 2}
  defp handle_valid_credentials(user, ip_address) do
    cond do
      User.active?(user) ->
        update_user_and_generate_tokens(user, ip_address)

      user.status == :suspended ->
        {:error, :suspended}

      true ->
        {:error, :inactive_user}
    end
  end

  defp update_user_and_generate_tokens(user, ip_address) do
    with {:ok, updated_user} <-
           user
           |> User.login_changeset(ip_address)
           |> Repo.update(),
         {:ok, tokens} <- Guardian.generate_token_pair(updated_user) do
      {:ok, updated_user, tokens}
    end
  end

  @doc """
  Verifies a JWT token and returns the user.
  """
  @spec verify_token(String.t()) :: {:ok, User.t(), map()} | {:error, atom()}
  def verify_token(token) do
    case Guardian.resource_from_token(token) do
      {:ok, user, claims} -> {:ok, user, claims}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Refreshes access token using refresh token.
  """
  @spec refresh_access_token(String.t()) :: {:ok, map()} | {:error, atom()}
  def refresh_access_token(refresh_token) do
    Guardian.refresh_token(refresh_token)
  end

  @doc """
  Revokes a token.
  """
  @spec revoke_token(String.t()) :: {:ok, map()} | {:error, atom()}
  def revoke_token(token) do
    Guardian.revoke(token)
  end

  @doc """
  Changes user role (admin only).
  """
  @spec change_role(User.t(), String.t()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def change_role(%User{} = user, new_role) do
    update_user(user, %{role: new_role})
  end

  @doc """
  Changes user status (admin only).
  """
  @spec change_status(User.t(), String.t()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def change_status(%User{} = user, new_status) do
    update_user(user, %{status: new_status})
  end

  # Private functions

  defp maybe_filter_by_role(query, nil), do: query
  defp maybe_filter_by_role(query, role), do: where(query, [u], u.role == ^role)

  defp maybe_filter_by_status(query, nil), do: query
  defp maybe_filter_by_status(query, status), do: where(query, [u], u.status == ^status)
end
