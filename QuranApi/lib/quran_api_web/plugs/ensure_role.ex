defmodule QuranApiWeb.Plugs.EnsureRole do
  @moduledoc """
  Plug to ensure the user has the required role.
  """
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  alias QuranApi.Auth.User

  def init(opts), do: opts

  def call(conn, roles) when is_list(roles) do
    user = Guardian.Plug.current_resource(conn)
    # Normalize roles to atoms for comparison
    normalized_roles =
      Enum.map(roles, fn
        role when is_binary(role) -> String.to_existing_atom(role)
        role when is_atom(role) -> role
      end)

    if user && user_has_role?(user, normalized_roles) do
      conn
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: %{message: "Insufficient permissions"}})
      |> halt()
    end
  end

  def call(conn, role) when is_binary(role) do
    call(conn, [role])
  end

  def call(conn, role) when is_atom(role) do
    call(conn, [role])
  end

  defp user_has_role?(%User{role: user_role}, roles) do
    user_role in roles
  end

  defp user_has_role?(_, _), do: false
end
