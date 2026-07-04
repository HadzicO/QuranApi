defmodule QuranApi.Quran.Ayah do
  @moduledoc """
  Schema for Ayah (Verse) in the Quran.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias QuranApi.Quran.{Audio, AyahTopic, Surah, Tafsir, Translation}

  @type t :: %__MODULE__{
          id: integer(),
          surah_id: integer(),
          ayah_number: integer(),
          global_number: integer(),
          arabic_text: String.t(),
          surah: Surah.t() | Ecto.Association.NotLoaded.t(),
          translations: [Translation.t()] | Ecto.Association.NotLoaded.t(),
          tafsirs: [Tafsir.t()] | Ecto.Association.NotLoaded.t(),
          audio: [Audio.t()] | Ecto.Association.NotLoaded.t(),
          ayah_topics: [AyahTopic.t()] | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "ayahs" do
    field :ayah_number, :integer
    field :global_number, :integer
    field :arabic_text, :string

    belongs_to :surah, Surah
    has_many :translations, Translation, foreign_key: :ayah_id
    has_many :tafsirs, Tafsir, foreign_key: :ayah_id
    has_many :audio, Audio, foreign_key: :ayah_id
    has_many :ayah_topics, AyahTopic, foreign_key: :ayah_id
    has_many :topics, through: [:ayah_topics, :topic]

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset for creating or updating an Ayah.
  """
  @spec changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def changeset(ayah, attrs) do
    ayah
    |> cast(attrs, [:surah_id, :ayah_number, :global_number, :arabic_text])
    |> validate_required([:surah_id, :ayah_number, :global_number, :arabic_text])
    |> validate_number(:ayah_number, greater_than: 0)
    |> validate_number(:global_number, greater_than: 0, less_than_or_equal_to: 6236)
    |> foreign_key_constraint(:surah_id)
    |> unique_constraint([:surah_id, :ayah_number])
    |> unique_constraint(:global_number)
  end
end
