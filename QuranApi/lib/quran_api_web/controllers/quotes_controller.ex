defmodule QuranApiWeb.QuotesController do
  use QuranApiWeb, :controller

  alias QuranApi.Quotes

  def get_random_quote(conn, _params) do
    quote = Quotes.get_random_quote()
    render(conn, "show.json", quote: quote)
  end

  def get_quote_with_translation(conn, %{"id" => id}) do
    translation = conn.params["translation"] || "bs"

    quote_with_translation = Quotes.get_quote_with_translation!(id, translation)
    quote_with_translation |> IO.inspect()

    render(conn, "show_translate.json", %{
      quote: quote_with_translation.quote,
      translation: quote_with_translation.translation
    })
  end
end
