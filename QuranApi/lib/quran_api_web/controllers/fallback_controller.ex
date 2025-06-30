defmodule QuranApiWeb.FallbackController do
  use QuranApiWeb, :controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(QuranApiWeb.ErrorView)
    |> render(:"404")
  end
end
