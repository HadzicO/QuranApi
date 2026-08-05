defmodule QuranApiWeb.Admin.AuthController do
  use QuranApiWeb, :controller

  alias QuranApi.Admin
  alias QuranApi.Auth

  action_fallback QuranApiWeb.FallbackController

  @doc """
  User login - POST /admin/login
  """
  def login(conn, %{"email" => email, "password" => password}) do
    ip_address = get_ip_address(conn)

    with {:ok, user, tokens} <- Auth.authenticate(email, password, ip_address) do
      # Log the action
      Admin.log_action(user, "login", "user", user.id, %{}, %{ip_address: ip_address})

      conn
      |> put_status(:ok)
      |> render(:login, user: user, tokens: tokens)
    end
  end

  def login(_conn, _params) do
    {:error, "Email and password are required"}
  end

  @doc """
  User logout - POST /admin/logout
  """
  def logout(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    token = Guardian.Plug.current_token(conn)

    if token do
      Auth.revoke_token(token)
      Admin.log_action(user, "logout", "user", user.id, %{}, %{})
    end

    conn
    |> put_status(:ok)
    |> json(%{message: "Logged out successfully"})
  end

  @doc """
  Get current user - GET /admin/me
  """
  def me(conn, _params) do
    user = Guardian.Plug.current_resource(conn)

    conn
    |> render(:user, user: user)
  end

  @doc """
  Refresh access token - POST /admin/refresh
  """
  def refresh(conn, %{"refresh_token" => refresh_token}) do
    with {:ok, tokens} <- Auth.refresh_access_token(refresh_token) do
      conn
      |> put_status(:ok)
      |> json(%{data: tokens})
    end
  end

  # Handle missing refresh_token
  def refresh(_conn, _params) do
    {:error, "Refresh token is required"}
  end

  defp get_ip_address(conn) do
    case Plug.Conn.get_req_header(conn, "x-forwarded-for") do
      [ip | _] -> ip
      [] -> to_string(:inet_parse.ntoa(conn.remote_ip))
    end
  end
end
