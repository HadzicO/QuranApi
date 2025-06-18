defmodule QuranApiWeb.QuotesController do
  use QuranApiWeb, :controller

  alias QuranApi.Quotes

  def get_random_quote(conn, _params) do
    quote = Quotes.get_random_quote()
    render(conn, "show.json", quote: quote)
  end

  def get_quote_with_translation(conn, %{"id" => id}) do
    language = Map.get(conn.params, "languageCode", "bs")

    case Quotes.get_quote_with_translation!(id, language) do
      {:ok, quote_with_translation} ->
        render(conn, "show_translate.json", %{
          quote: quote_with_translation.quote,
          translation: quote_with_translation.translation
        })

        render_error(conn, :not_found, "Translation not found")
    end
  end

  defp render_error(conn, status, message) do
    conn
    |> put_status(status)
    |> json(%{error: message})
  end
end
