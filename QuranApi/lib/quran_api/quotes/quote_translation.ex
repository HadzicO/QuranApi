defmodule QuranApi.Quotes.QuoteTranslation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "quote_translations" do
    field :language_code, :string
    field :content, :string
    field :quote_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(quote_translation, attrs) do
    quote_translation
    |> cast(attrs, [:language_code, :content])
    |> validate_required([:language_code, :content])
  end
end
