defmodule QuranApi.Chapters.Chapter do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chapters" do
    field :name, :string
    field :number, :integer
    field :number_of_quote, :integer
    field :publication, :string
    belongs_to :book, QuranApi.Books.Book
    has_many :quotes, QuranApi.Quotes.Quote
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(chapter, attrs) do
    chapter
    |> cast(attrs, [:name, :number, :number_of_quote, :publication, :book_id])
    |> validate_required([:name, :number, :number_of_quote, :publication, :book_id])
  end
end
