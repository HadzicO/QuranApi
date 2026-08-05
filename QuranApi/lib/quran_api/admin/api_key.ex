defmodule QuranApi.Admin.ApiKey do
  @moduledoc """
  Schema for managing API keys.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias QuranApi.Auth.User

  @type t :: %__MODULE__{
          id: integer(),
          user_id: integer() | nil,
          key_hash: String.t(),
          name: String.t(),
          description: String.t() | nil,
          status: String.t(),
          last_used_at: DateTime.t() | nil,
          last_used_ip: String.t() | nil,
          expires_at: DateTime.t() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "api_keys" do
    belongs_to :user, User
    field :key, :string, virtual: true, redact: true
    field :key_hash, :string, redact: true
    field :name, :string
    field :description, :string
    field :status, :string, default: "active"
    field :last_used_at, :utc_datetime
    field :last_used_ip, :string
    field :expires_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset for creating an API key.
  """
  @spec changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def changeset(api_key, attrs) do
    api_key
    |> cast(attrs, [:user_id, :name, :description, :expires_at])
    |> validate_required([:name])
    |> validate_length(:name, min: 3, max: 100)
    |> put_key_hash()
  end

  @doc """
  Changeset for updating API key usage.
  """
  @spec usage_changeset(Ecto.Schema.t(), String.t()) :: Ecto.Changeset.t()
  def usage_changeset(api_key, ip_address) do
    change(api_key, %{
      last_used_at: DateTime.utc_now(),
      last_used_ip: ip_address
    })
  end

  @doc """
  Changeset for revoking an API key.
  """
  @spec revoke_changeset(Ecto.Schema.t()) :: Ecto.Changeset.t()
  def revoke_changeset(api_key) do
    change(api_key, %{status: "revoked"})
  end

  defp put_key_hash(changeset) do
    if changeset.valid? do
      key = generate_key()
      hash = hash_key(key)

      changeset
      |> put_change(:key, key)
      |> put_change(:key_hash, hash)
    else
      changeset
    end
  end

  defp generate_key do
    :crypto.strong_rand_bytes(36)
    |> Base.encode64(padding: false)
    |> binary_part(0, 48)
  end

  defp hash_key(key) do
    :crypto.hash(:sha256, key)
    |> Base.encode16(case: :lower)
  end

  @doc """
  Verifies an API key against the stored hash.
  """
  @spec verify_key?(String.t(), String.t()) :: boolean()
  def verify_key?(key, stored_hash) do
    hash_key(key) == stored_hash
  end
end
