defmodule QuranApi.QuotesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `QuranApi.Quotes` context.
  """

  @doc """
  Generate a quote.
  """
  def quote_fixture(attrs \\ %{}) do
    {:ok, quote} =
      attrs
      |> Enum.into(%{
        content: "some content",
        quote_order: 42
      })
      |> QuranApi.Quotes.create_quote()

    quote
  end

  @doc """
  Generate a quote_translation.
  """
  def quote_translation_fixture(attrs \\ %{}) do
    {:ok, quote_translation} =
      attrs
      |> Enum.into(%{
        content: "some content",
        language_code: "some language_code"
      })
      |> QuranApi.Quotes.create_quote_translation()

    quote_translation
  end

  @doc """
  Generate a languages.
  """
  def languages_fixture(attrs \\ %{}) do
    {:ok, languages} =
      attrs
      |> Enum.into(%{
        language_code: "some language_code",
        language_name: "some language_name"
      })
      |> QuranApi.Quotes.create_languages()

    languages
  end
end
