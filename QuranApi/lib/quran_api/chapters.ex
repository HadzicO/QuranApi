defmodule QuranApi.Chapters do
  import Ecto.Query, warn: false
  alias QuranApi.Repo
  alias QuranApi.Books.Book
  alias QuranApi.Chapters.Chapter
  alias QuranApi.Queries

  # List all chapters
  def list_chapters do
    Repo.all(Chapter)
  end

  # Get a single chapter by id
  def get_chapter!(id), do: Repo.get!(Chapter, id)

  # Create a chapter
  def create_chapter(attrs \\ %{}) do
    %Chapter{}
    |> Chapter.changeset(attrs)
    |> Repo.insert()
  end

  # Update a chapter
  def update_chapter(%Chapter{} = chapter, attrs) do
    chapter
    |> Chapter.changeset(attrs)
    |> Repo.update()
  end

  # Delete a chapter
  def delete_chapter(%Chapter{} = chapter) do
    Repo.delete(chapter)
  end

  # Returns an Ecto changeset for tracking chapter changes
  def change_chapter(%Chapter{} = chapter, attrs \\ %{}) do
    Chapter.changeset(chapter, attrs)
  end

  def get_chapter(book_name, chapter_name, language_code) do
    chapter = Queries.get_chapter_quote_by_name(book_name, chapter_name)
    quote_translation = Queries.get_quote_by_chapter_id(chapter.id, language_code)

    %{
      chapter: chapter,
      quote: quote_translation
    }
  end

  def get_chapter(book_name, chapter_name, language_code, quote_from, quote_to) do
    number_of_quotes = get_number_of_quotes(book_name, chapter_name)

    {quote_from, quote_to} =
      if is_nil(quote_from) or is_nil(quote_to) do
        {1, number_of_quotes}
      else
        {quote_from, quote_to}
      end

    quote_to =
      if quote_to < number_of_quotes do
        number_of_quotes
      else
        quote_to
      end

    chapter = Queries.get_chapter_quote_by_name(book_name, chapter_name)

    quote_translation =
      Queries.get_quote_by_chapter_id(chapter.id, language_code, quote_from, quote_to)

    %{
      chapter: chapter,
      quote: quote_translation
    }
  end

  def get_number_of_quotes(book_name, chapter_name) do
    Chapter
    |> join(:inner, [c], b in Book, on: c.book_id == b.id)
    |> where([c, b], b.original_title == ^book_name and c.name == ^chapter_name)
    |> select([c], c.number_of_quote)
    |> Repo.one()
  end
end
