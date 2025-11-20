defmodule QuranApiWeb.Plugs.RolePlug do
  @moduledoc """
  A plug for enforcing role-based access control in the QuranApi web application.

  This plug checks if the current user has one of the required roles before allowing access to the requested resource.
  If the user does not have sufficient permissions, it responds with a 403 Forbidden status and a JSON error message.

  ## Usage

  Add this plug to your pipeline or controller, specifying the required roles:

    plug QuranApiWeb.Plugs.RolePlug, [:admin, :moderator]

  ## Assigns

  - `conn.assigns.current_user` - The current user struct, which must have a `role` field.

  ## Options

  - `required_roles` - A list of roles permitted to access the resource.

  ## Responses

  - Continues the request if the user has a permitted role.
  - Halts the connection and returns a 403 Forbidden JSON error if not.
  """

  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, required_roles) do
    user = conn.assigns[:current_user]

    cond do
      is_nil(user) or is_nil(user[:role]) ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Insufficient permissions"})
        |> halt()

      user.role in required_roles ->
        conn

      true ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Insufficient permissions"})
        |> halt()
    end
  end
end
