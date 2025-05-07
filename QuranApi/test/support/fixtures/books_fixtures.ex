defmodule QuranApi.BooksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `QuranApi.Books` context.
  """

  @doc """
  Generate a book.
  """
  def book_fixture(attrs \\ %{}) do
    {:ok, book} =
      attrs
      |> Enum.into(%{
        author: "some author",
        original_title: "some original_title",
        year_published: 42
      })
      |> QuranApi.Books.create_book()

    book
  end
end
