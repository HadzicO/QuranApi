defmodule QuranApiWeb.QuotesJSON do
  alias QuranApi.Quotes.Quote

  def show(%{quote: %Quote{} = quote}) do
    %{
      id: quote.id,
      content: quote.content,
      book_id: quote.book_id,
      inserted_at: quote.inserted_at,
      updated_at: quote.updated_at
    }
  end
end
