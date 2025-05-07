defmodule QuranApi.Quotes.Quote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "quotes" do
    field :quote_order, :integer
    field :content, :string
    field :book_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(quote, attrs) do
    quote
    |> cast(attrs, [:quote_order, :content])
    |> validate_required([:quote_order, :content])
  end
end
