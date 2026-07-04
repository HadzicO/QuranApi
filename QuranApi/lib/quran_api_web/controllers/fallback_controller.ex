defmodule QuranApiWeb.FallbackController do
  use QuranApiWeb, :controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: QuranApiWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, message}) when is_binary(message) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: message})
  end

  def call(conn, {:error, errors}) when is_list(errors) do
    conn
    |> put_status(:bad_request)
    |> json(%{errors: errors})
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: QuranApiWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end
end
