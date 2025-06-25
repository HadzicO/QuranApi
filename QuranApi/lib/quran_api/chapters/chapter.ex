defmodule QuranApi.Chapters.Chapter do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chapters" do
    field :name, :string
    field :number, :integer
    field :number_of_quote, :integer
    field :publication, :string
    field :book_id, :id
    has_many :quotes, QuranApi.Quotes.Quote
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(chapter, attrs) do
    chapter
    |> cast(attrs, [:name, :number, :number_of_quote, :publication])
    |> validate_required([:name, :number, :number_of_quote, :publication])
  end
end
