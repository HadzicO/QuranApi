defmodule QuranApi.BooksTest do
  use QuranApi.DataCase

  alias QuranApi.Books

  describe "books" do
    alias QuranApi.Books.Book

    import QuranApi.BooksFixtures

    @invalid_attrs %{author: nil, original_title: nil, year_published: nil}

    test "list_books/0 returns all books" do
      book = book_fixture()
      assert Books.list_books() == [book]
    end

    test "get_book!/1 returns the book with given id" do
      book = book_fixture()
      assert Books.get_book!(book.id) == book
    end

    test "create_book/1 with valid data creates a book" do
      valid_attrs = %{author: "some author", original_title: "some original_title", year_published: 42}

      assert {:ok, %Book{} = book} = Books.create_book(valid_attrs)
      assert book.author == "some author"
      assert book.original_title == "some original_title"
      assert book.year_published == 42
    end

    test "create_book/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Books.create_book(@invalid_attrs)
    end

    test "update_book/2 with valid data updates the book" do
      book = book_fixture()
      update_attrs = %{author: "some updated author", original_title: "some updated original_title", year_published: 43}

      assert {:ok, %Book{} = book} = Books.update_book(book, update_attrs)
      assert book.author == "some updated author"
      assert book.original_title == "some updated original_title"
      assert book.year_published == 43
    end

    test "update_book/2 with invalid data returns error changeset" do
      book = book_fixture()
      assert {:error, %Ecto.Changeset{}} = Books.update_book(book, @invalid_attrs)
      assert book == Books.get_book!(book.id)
    end

    test "delete_book/1 deletes the book" do
      book = book_fixture()
      assert {:ok, %Book{}} = Books.delete_book(book)
      assert_raise Ecto.NoResultsError, fn -> Books.get_book!(book.id) end
    end

    test "change_book/1 returns a book changeset" do
      book = book_fixture()
      assert %Ecto.Changeset{} = Books.change_book(book)
    end
  end
end
