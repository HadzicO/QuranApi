defmodule QuranApiWeb.ChaptersJSON do
  @moduledoc """
  JSON rendering for chapters.
  """

  def render("index.json", %{chapters: chapters}) do
    %{data: Enum.map(chapters, &chapter_to_map/1)}
  end

  def render("show.json", %{chapter: chapter}) do
    %{data: chapter_to_map(chapter)}
  end

  defp chapter_to_map(chapter) do
    %{
      quotes: Enum.map(chapter.quote, &quote_to_map/1),
      chapter: show_chapter(chapter.chapter)
    }
  end

  defp show_chapter(chapter) do
    %{
      id: chapter.id,
      book_title: chapter.book_name,
      chapter_name: chapter.chapter_name,
      chapter_number: chapter.chapter_number,
      number_of_quote: chapter.number_of_quote,
      publication: chapter.publication
    }
  end

  defp quote_to_map(quote) do
    %{
      quote_order: quote.quote_order,
      content: quote.content,
      translation: quote.translation
    }
  end
end
