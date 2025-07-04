defmodule QuranApi.Quotes.Quote do
  @moduledoc """
  Represents a quote in the Quran.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "quotes" do
    field :quote_order, :integer
    field :content, :string
    belongs_to :chapter, QuranApi.Chapters.Chapter
    has_many :quote_translations, QuranApi.Quotes.QuoteTranslation, foreign_key: :quote_id
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(quote, attrs) do
    quote
    |> cast(attrs, [:quote_order, :content])
    |> validate_required([:quote_order, :content])
  end
end
