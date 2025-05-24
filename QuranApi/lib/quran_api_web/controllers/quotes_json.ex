defmodule QuranApiWeb.QuotesJSON do

  def show(%{quote: quote}) do
    %{data: data_quote_minimal(quote)}
  end

  def show_translate(%{quote: quote, translation: translation}) do
    %{
      quote: data_quote_minimal(quote),
      translation: data_translate(translation)
    }
  end

  defp data_quote_minimal(quote) do
    %{
      id: quote.id,
      content: quote.content
    }
  end

  defp data_translate(translation) do
    %{
      language_code: translation.language_code,
      content: translation.content
    }
  end
end
