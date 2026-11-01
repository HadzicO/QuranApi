defmodule QuranApiWeb.AuthController do
  use QuranApiWeb, :controller

  require Logger

  alias QuranApi.Accounts
  alias QuranApi.Guardian

  def login(conn, %{"email" => email, "password" => password})
      when is_binary(email) and is_binary(password) do
    with {:ok, user} <- Accounts.authenticate_user(email, password),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      json(conn, %{
        token: token,
        user: %{id: user.id, email: user.email, role: user.role}
      })
    else
      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})

      {:error, reason} ->
        Logger.error("Token generation failed: #{inspect(reason)}")

        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Could not issue token"})
    end
  end

  def login(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "email and password are required"})
  end

  def logout(conn, _params) do
    with token when is_binary(token) <- Guardian.Plug.current_token(conn),
         {:ok, _claims} <- Guardian.revoke(token) do
      json(conn, %{message: "Logged out successfully"})
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid or missing token"})
    end
  end
end
