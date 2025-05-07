defmodule QuranApi.Quotes do
  @moduledoc """
  The Quotes context.
  """

  import Ecto.Query, warn: false
  alias QuranApi.Repo

  alias QuranApi.Quotes.Quote

  @doc """
  Returns the list of quotes.

  ## Examples

      iex> list_quotes()
      [%Quote{}, ...]

  """
  def list_quotes do
    Repo.all(Quote)
  end

  @doc """
  Gets a single quote.

  Raises `Ecto.NoResultsError` if the Quote does not exist.

  ## Examples

      iex> get_quote!(123)
      %Quote{}

      iex> get_quote!(456)
      ** (Ecto.NoResultsError)

  """
  def get_quote!(id), do: Repo.get!(Quote, id)

  @doc """
  Gets a random quote.
  ## Examples

      iex> get_random_quote()
      %Quote{}

  """
  def get_random_quote do
    Quote
    |> order_by(fragment("RANDOM()"))
    |> limit(1)
    |> Repo.one()
  end

  @doc """
  Creates a quote.

  ## Examples

      iex> create_quote(%{field: value})
      {:ok, %Quote{}}

      iex> create_quote(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_quote(attrs \\ %{}) do
    %Quote{}
    |> Quote.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a quote.

  ## Examples

      iex> update_quote(quote, %{field: new_value})
      {:ok, %Quote{}}

      iex> update_quote(quote, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_quote(%Quote{} = quote, attrs) do
    quote
    |> Quote.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a quote.

  ## Examples

      iex> delete_quote(quote)
      {:ok, %Quote{}}

      iex> delete_quote(quote)
      {:error, %Ecto.Changeset{}}

  """
  def delete_quote(%Quote{} = quote) do
    Repo.delete(quote)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking quote changes.

  ## Examples

      iex> change_quote(quote)
      %Ecto.Changeset{data: %Quote{}}

  """
  def change_quote(%Quote{} = quote, attrs \\ %{}) do
    Quote.changeset(quote, attrs)
  end

  alias QuranApi.Quotes.QuoteTranslation

  @doc """
  Returns the list of quote_translations.

  ## Examples

      iex> list_quote_translations()
      [%QuoteTranslation{}, ...]

  """
  def list_quote_translations do
    Repo.all(QuoteTranslation)
  end

  @doc """
  Gets a single quote_translation.

  Raises `Ecto.NoResultsError` if the Quote translation does not exist.

  ## Examples

      iex> get_quote_translation!(123)
      %QuoteTranslation{}

      iex> get_quote_translation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_quote_translation!(id), do: Repo.get!(QuoteTranslation, id)

  @doc """
  Creates a quote_translation.

  ## Examples

      iex> create_quote_translation(%{field: value})
      {:ok, %QuoteTranslation{}}

      iex> create_quote_translation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_quote_translation(attrs \\ %{}) do
    %QuoteTranslation{}
    |> QuoteTranslation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a quote_translation.

  ## Examples

      iex> update_quote_translation(quote_translation, %{field: new_value})
      {:ok, %QuoteTranslation{}}

      iex> update_quote_translation(quote_translation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_quote_translation(%QuoteTranslation{} = quote_translation, attrs) do
    quote_translation
    |> QuoteTranslation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a quote_translation.

  ## Examples

      iex> delete_quote_translation(quote_translation)
      {:ok, %QuoteTranslation{}}

      iex> delete_quote_translation(quote_translation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_quote_translation(%QuoteTranslation{} = quote_translation) do
    Repo.delete(quote_translation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking quote_translation changes.

  ## Examples

      iex> change_quote_translation(quote_translation)
      %Ecto.Changeset{data: %QuoteTranslation{}}

  """
  def change_quote_translation(%QuoteTranslation{} = quote_translation, attrs \\ %{}) do
    QuoteTranslation.changeset(quote_translation, attrs)
  end
end
