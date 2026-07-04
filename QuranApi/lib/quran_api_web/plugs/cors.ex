defmodule QuranApiWeb.Plugs.CORS do
  @moduledoc """
  Simple CORS plug to allow cross-origin requests to the API.
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> put_resp_header("access-control-allow-origin", "*")
    |> put_resp_header("access-control-allow-methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
    |> put_resp_header("access-control-allow-headers", "content-type, authorization, accept")
    |> put_resp_header("access-control-expose-headers", "content-length, content-type")
    |> handle_preflight()
  end

  defp handle_preflight(%Plug.Conn{method: "OPTIONS"} = conn) do
    conn
    |> send_resp(204, "")
    |> halt()
  end

  defp handle_preflight(conn), do: conn
end
