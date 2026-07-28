defmodule QuranApi.AuthFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `QuranApi.Auth` context.
  """

  alias QuranApi.Auth
  alias QuranApi.Auth.Guardian

  @doc """
  Generate a unique user email.
  """
  def unique_user_email, do: "user#{System.unique_integer([:positive])}@example.com"

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: unique_user_email(),
        password: "SecurePassword123",
        first_name: "Test",
        last_name: "User",
        role: "editor",
        status: "active"
      })
      |> Auth.create_user()

    user
  end

  @doc """
  Generate an admin user.
  """
  def admin_fixture(attrs \\ %{}) do
    user_fixture(Map.merge(attrs, %{role: "admin"}))
  end

  @doc """
  Generate a readonly user.
  """
  def readonly_fixture(attrs \\ %{}) do
    user_fixture(Map.merge(attrs, %{role: "readonly"}))
  end

  @doc """
  Generate a valid JWT token for a user.
  """
  def valid_user_token(user) do
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    token
  end
end
