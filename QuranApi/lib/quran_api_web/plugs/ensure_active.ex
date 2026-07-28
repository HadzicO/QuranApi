defmodule QuranApiWeb.Plugs.EnsureActive do
  @moduledoc """
  Plug to ensure the user account is active.
  """
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  alias QuranApi.Auth.User

  def init(opts), do: opts

  def call(conn, _opts) do
    user = Guardian.Plug.current_resource(conn)

    if user && User.active?(user) do
      conn
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: %{message: "Account is not active"}})
      |> halt()
    end
  end
end
