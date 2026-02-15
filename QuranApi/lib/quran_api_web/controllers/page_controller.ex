defmodule QuranApiWeb.PageController do
  use QuranApiWeb, :controller

  def index(conn, _params) do
    json(conn, %{
      message: "Welcome to Quran API",
      version: "0.1.0",
      endpoints: %{
        quotes: "/v1/quotes",
        quote_by_id: "/v1/quotes/:id",
        chapter: "/v1/chapters"
      }
    })
  end
end
