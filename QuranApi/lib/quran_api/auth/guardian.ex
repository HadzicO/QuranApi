defmodule QuranApi.Auth.Guardian do
  @moduledoc """
  Guardian implementation for JWT authentication.
  """
  use Guardian, otp_app: :quran_api

  alias QuranApi.Auth

  @doc """
  Encodes the user ID into the JWT token.
  """
  def subject_for_token(%{id: id}, _claims) do
    {:ok, to_string(id)}
  end

  def subject_for_token(_, _) do
    {:error, :invalid_resource}
  end

  @doc """
  Retrieves the user from the JWT token.
  """
  def resource_from_claims(%{"sub" => id}) do
    case Auth.get_user(id) do
      nil -> {:error, :user_not_found}
      user -> {:ok, user}
    end
  end

  def resource_from_claims(_claims) do
    {:error, :invalid_claims}
  end

  @doc """
  Builds claims for the JWT token.
  """
  def build_claims(claims, %{id: _id, role: role, email: email}, _opts) do
    {:ok,
     claims
     |> Map.put("role", role)
     |> Map.put("email", email)}
  end

  def build_claims(claims, _resource, _opts), do: {:ok, claims}

  @doc """
  Generates a token pair (access token and refresh token).
  """
  def generate_token_pair(user) do
    with {:ok, access_token, _claims} <-
           encode_and_sign(user, %{}, token_type: "access", ttl: {1, :hour}),
         {:ok, refresh_token, _claims} <-
           encode_and_sign(user, %{}, token_type: "refresh", ttl: {7, :day}) do
      {:ok, %{access_token: access_token, refresh_token: refresh_token}}
    end
  end

  @doc """
  Refreshes an access token using a refresh token.
  """
  def refresh_token(refresh_token) when is_binary(refresh_token) do
    # First, decode and verify the refresh token
    with {:ok, claims} <- __MODULE__.decode_and_verify(refresh_token),
         {:ok, user} <- resource_from_claims(claims) do
      # Check if it's a refresh token (optional - for extra security)
      case claims["typ"] do
        "refresh" ->
          # User found, generate new token pair
          generate_token_pair(user)

        _ ->
          # Wrong token type
          {:error, :invalid_token_type}
      end
    else
      # Normalize all errors to :invalid_token for consistency
      _ -> {:error, :invalid_token}
    end
  end

  def refresh_token(_), do: {:error, :invalid_token}
end
