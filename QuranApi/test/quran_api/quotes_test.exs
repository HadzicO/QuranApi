defmodule QuranApi.QuotesTest do
  use QuranApi.DataCase

  alias QuranApi.Quotes

  describe "quotes" do
    alias QuranApi.Quotes.Quote

    import QuranApi.QuotesFixtures

    @invalid_attrs %{quote_order: nil, content: nil}

    test "list_quotes/0 returns all quotes" do
      quote = quote_fixture()
      assert Quotes.list_quotes() == [quote]
    end

    test "get_quote!/1 returns the quote with given id" do
      quote = quote_fixture()
      assert Quotes.get_quote!(quote.id) == quote
    end

    test "create_quote/1 with valid data creates a quote" do
      valid_attrs = %{quote_order: 42, content: "some content"}

      assert {:ok, %Quote{} = quote} = Quotes.create_quote(valid_attrs)
      assert quote.quote_order == 42
      assert quote.content == "some content"
    end

    test "create_quote/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Quotes.create_quote(@invalid_attrs)
    end

    test "update_quote/2 with valid data updates the quote" do
      quote = quote_fixture()
      update_attrs = %{quote_order: 43, content: "some updated content"}

      assert {:ok, %Quote{} = quote} = Quotes.update_quote(quote, update_attrs)
      assert quote.quote_order == 43
      assert quote.content == "some updated content"
    end

    test "update_quote/2 with invalid data returns error changeset" do
      quote = quote_fixture()
      assert {:error, %Ecto.Changeset{}} = Quotes.update_quote(quote, @invalid_attrs)
      assert quote == Quotes.get_quote!(quote.id)
    end

    test "delete_quote/1 deletes the quote" do
      quote = quote_fixture()
      assert {:ok, %Quote{}} = Quotes.delete_quote(quote)
      assert_raise Ecto.NoResultsError, fn -> Quotes.get_quote!(quote.id) end
    end

    test "change_quote/1 returns a quote changeset" do
      quote = quote_fixture()
      assert %Ecto.Changeset{} = Quotes.change_quote(quote)
    end
  end

  describe "quote_translations" do
    alias QuranApi.Quotes.QuoteTranslation

    import QuranApi.QuotesFixtures

    @invalid_attrs %{language_code: nil, content: nil}

    test "list_quote_translations/0 returns all quote_translations" do
      quote_translation = quote_translation_fixture()
      assert Quotes.list_quote_translations() == [quote_translation]
    end

    test "get_quote_translation!/1 returns the quote_translation with given id" do
      quote_translation = quote_translation_fixture()
      assert Quotes.get_quote_translation!(quote_translation.id) == quote_translation
    end

    test "create_quote_translation/1 with valid data creates a quote_translation" do
      valid_attrs = %{language_code: "some language_code", content: "some content"}

      assert {:ok, %QuoteTranslation{} = quote_translation} = Quotes.create_quote_translation(valid_attrs)
      assert quote_translation.language_code == "some language_code"
      assert quote_translation.content == "some content"
    end

    test "create_quote_translation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Quotes.create_quote_translation(@invalid_attrs)
    end

    test "update_quote_translation/2 with valid data updates the quote_translation" do
      quote_translation = quote_translation_fixture()
      update_attrs = %{language_code: "some updated language_code", content: "some updated content"}

      assert {:ok, %QuoteTranslation{} = quote_translation} = Quotes.update_quote_translation(quote_translation, update_attrs)
      assert quote_translation.language_code == "some updated language_code"
      assert quote_translation.content == "some updated content"
    end

    test "update_quote_translation/2 with invalid data returns error changeset" do
      quote_translation = quote_translation_fixture()
      assert {:error, %Ecto.Changeset{}} = Quotes.update_quote_translation(quote_translation, @invalid_attrs)
      assert quote_translation == Quotes.get_quote_translation!(quote_translation.id)
    end

    test "delete_quote_translation/1 deletes the quote_translation" do
      quote_translation = quote_translation_fixture()
      assert {:ok, %QuoteTranslation{}} = Quotes.delete_quote_translation(quote_translation)
      assert_raise Ecto.NoResultsError, fn -> Quotes.get_quote_translation!(quote_translation.id) end
    end

    test "change_quote_translation/1 returns a quote_translation changeset" do
      quote_translation = quote_translation_fixture()
      assert %Ecto.Changeset{} = Quotes.change_quote_translation(quote_translation)
    end
  end
end
