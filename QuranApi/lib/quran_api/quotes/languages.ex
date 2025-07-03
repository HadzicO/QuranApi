defmodule QuranApi.Quotes.Languages do
  @moduledoc """
  Represents a language in which quotes can be translated.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "language" do
    field :language_name, :string
    field :language_code, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(languages, attrs) do
    languages
    |> cast(attrs, [:language_name, :language_code])
    |> validate_required([:language_name, :language_code])
  end
end
