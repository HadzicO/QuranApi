defmodule QuranApiWeb.FallbackController do
  use QuranApiWeb, :controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: QuranApiWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> json(%{error: %{message: "Insufficient permissions"}})
  end

  def call(conn, {:error, :bad_request}) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: %{message: "Bad request"}})
  end

  def call(conn, {:error, :suspended}) do
    conn
    |> put_status(:forbidden)
    |> json(%{error: %{message: "Account is suspended"}})
  end

  def call(conn, {:error, :inactive_user}) do
    conn
    |> put_status(:forbidden)
    |> json(%{error: %{message: "Account is inactive"}})
  end

  def call(conn, {:error, :invalid_credentials}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: %{message: "Invalid credentials"}})
  end

  def call(conn, {:error, :invalid_token}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: %{message: "Invalid token"}})
  end

  def call(conn, {:error, :invalid_token_type}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: %{message: "Invalid token type"}})
  end

  def call(conn, {:error, :invalid_refresh_token}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: %{message: "Invalid refresh token"}})
  end

  def call(conn, {:error, :user_not_found}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: %{message: "User not found"}})
  end

  def call(conn, {:error, :invalid_claims}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: %{message: "Invalid token claims"}})
  end

  def call(conn, {:error, message}) when is_binary(message) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: %{message: message}})
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

  # Catch-all for other errors
  def call(conn, {:error, _error}) do
    conn
    |> put_status(:internal_server_error)
    |> json(%{error: %{message: "An internal error occurred"}})
  end
end
