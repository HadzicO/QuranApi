defmodule QuranApiWeb.ChaptersController do
  use QuranApiWeb, :controller

  alias QuranApi.Chapters

  action_fallback QuranApiWeb.FallbackController

  def get_chapter(conn, %{"id" => id}) do
    chapter = Chapters.get_chapter!(id)
    render(conn, "show.json", chapter: chapter)
  end

  def get_chapter_by_name(conn, %{
        "book_name" => book_name,
        "chapter_name" => chapter_name,
        "language_code" => language_code
      }) do
    quote_from = Map.get(conn.query_params, "quote_from")
    quote_to = Map.get(conn.query_params, "quote_to")

    chapter =
      if is_nil(quote_from) or is_nil(quote_to) do
        Chapters.get_chapter(book_name, chapter_name, language_code)
      else
        Chapters.get_chapter(book_name, chapter_name, language_code, quote_from, quote_to)
      end

    render(conn, "show.json", chapter: chapter)
  end
end
