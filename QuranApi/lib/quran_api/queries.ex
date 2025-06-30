defmodule QuranApi.Queries do
  @moduledoc """
  Provides query functions for QuranApi.
  """
  import Ecto.Query
  alias QuranApi.Chapters.Chapter
  alias QuranApi.Books.Book
  alias QuranApi.Quotes.Quote
  alias QuranApi.Repo

  def get_chapter_quote_by_name(book_name, chapter_name) do
    Chapter
    |> join(:inner, [c], b in Book, on: c.book_id == b.id)
    |> where([c, b], b.original_title == ^book_name and c.name == ^chapter_name)
    |> select([c, b], %{
      id: c.id,
      book_name: b.original_title,
      chapter_name: c.name,
      chapter_number: c.number,
      number_of_quote: c.number_of_quote,
      publication: c.publication
    })
    |> Repo.one()
  end

  def get_quote_by_chapter_id(chapter_id, language_code) do
    Quote
    |> join(:inner, [q], qt in assoc(q, :quote_translations))
    |> where([q, qt], q.chapter_id == ^chapter_id and qt.language_code == ^language_code)
    |> select([q, qt], %{
      id: q.id,
      quote_order: q.quote_order,
      content: q.content,
      translation: qt.content
    })
    |> Repo.all()
  end

  def get_quote_by_chapter_id(chapter_id, language_code, quote_from, quote_to) do
    Quote
    |> join(:inner, [q], qt in assoc(q, :quote_translations))
    |> where(
      [q, qt],
      q.chapter_id == ^chapter_id and qt.language_code == ^language_code and
        q.quote_order >= ^quote_from and q.quote_order <= ^quote_to
    )
    |> select([q, qt], %{
      id: q.id,
      quote_order: q.quote_order,
      content: q.content,
      translation: qt.content
    })
    |> Repo.all()
  end
end
