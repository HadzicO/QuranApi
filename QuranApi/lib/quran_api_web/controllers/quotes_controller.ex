
defmodule QuranApiWeb.QuotesController do
  use QuranApiWeb, :controller

  alias QuranApi.Quotes

  def get_random_quote(conn, _params) do
    quote = Quotes.get_random_quote()
    render(conn, "show.json", quote: quote)
  end
end
