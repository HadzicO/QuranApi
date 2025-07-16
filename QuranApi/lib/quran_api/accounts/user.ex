defmodule QuranApi.Accounts.User do
  @moduledoc """
  Represents a user in the QuranApi application.

  This schema defines the structure of the `users` table, including fields for role, email, password hash, and activation status.
  It provides a changeset function for validating and casting user attributes, enforcing required fields and unique email constraint.
  Includes a helper function to verify a user's password using Bcrypt.

  ## Fields

    * `:role` - The role of the user (e.g., admin, user).
    * `:email` - The user's email address.
    * `:password_hash` - The hashed password for authentication.
    * `:is_active` - Boolean indicating if the user account is active.

  ## Functions

    * `changeset/2` - Builds a changeset for user creation and updates.
    * `valid_password?/2` - Verifies a plain-text password against the stored hash.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @roles ["admin", "content_writer", "content_reviewer"]

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :role, :string, default: "content_writer"
    field :is_active, :boolean, default: true

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :role, :is_active])
    |> validate_required([:email, :password, :role])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/)
    |> validate_inclusion(:role, @roles)
    |> validate_length(:password, min: 6)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    change(changeset, password_hash: Bcrypt.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset

  def valid_password?(user, password) do
    Bcrypt.verify_pass(password, user.password_hash)
  end
end
