defmodule QuranApi.Books.Book do
  @moduledoc """
  Represents a book in the Quran API.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "books" do
    field :author, :string
    field :original_title, :string
    field :year_published, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:original_title, :author, :year_published])
    |> validate_required([:original_title, :author, :year_published])
  end
end
