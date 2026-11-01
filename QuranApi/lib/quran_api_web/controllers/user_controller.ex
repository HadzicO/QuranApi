defmodule QuranApiWeb.UserController do
  use QuranApiWeb, :controller

  def index(conn, _params) do
    json(conn, %{users: []})
  end

  def show(conn, %{"id" => id}) do
    json(conn, %{user: %{id: id}})
  end

  def create(conn, user_params) do
    json(conn, %{message: "User created", params: user_params})
  end
end
