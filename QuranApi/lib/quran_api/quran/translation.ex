defmodule QuranApi.Quran.Translation do
  @moduledoc """
  Schema for Ayah translations.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias QuranApi.Quran.Ayah

  @type t :: %__MODULE__{
          id: integer(),
          ayah_id: integer(),
          language_code: String.t(),
          translator: String.t(),
          text: String.t(),
          ayah: Ayah.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "translations" do
    field :language_code, :string
    field :translator, :string
    field :text, :string

    belongs_to :ayah, Ayah

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset for creating or updating a Translation.
  """
  @spec changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def changeset(translation, attrs) do
    translation
    |> cast(attrs, [:ayah_id, :language_code, :translator, :text])
    |> validate_required([:ayah_id, :language_code, :translator, :text])
    |> validate_length(:language_code, is: 2)
    |> foreign_key_constraint(:ayah_id)
    |> unique_constraint([:ayah_id, :language_code, :translator])
  end
end
