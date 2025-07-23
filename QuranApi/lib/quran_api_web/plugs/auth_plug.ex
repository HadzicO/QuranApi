defmodule QuranApiWeb.Plugs.AuthPlug do
  @moduledoc """
  A plug for authenticating requests in the QuranApi application.

  This plug checks if the current connection has an authenticated user resource using `Guardian`.
  If authentication fails, it responds with a 401 Unauthorized status and a JSON error message.
  If authentication succeeds, it assigns the authenticated user to `:current_user` in the connection.

  ## Usage

  Add this plug to your pipeline to protect routes that require authentication.

  ## Assigns

  - `:current_user` - The authenticated user resource.
  """

  import Plug.Conn

  alias QuranApi.Guardian

  def init(opts), do: opts

  def call(conn, _opts) do
    case Guardian.Plug.current_resource(conn) do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> put_resp_content_type("application/json")
        |> send_resp(
          :unauthorized,
          Jason.encode!(%{error: "Authentication required"})
        )
        |> halt()

      user ->
        assign(conn, :current_user, user)
    end
  end
end
