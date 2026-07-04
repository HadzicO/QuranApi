defmodule QuranApi.Quran.Surah do
  @moduledoc """
  Schema for Surah (Chapter) in the Quran.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias QuranApi.Quran.Ayah

  @type t :: %__MODULE__{
          id: integer(),
          chapter_number: integer(),
          name_ar: String.t(),
          name_en: String.t(),
          name_bs: String.t() | nil,
          revelation_type: String.t(),
          verses_count: integer(),
          ayahs: [Ayah.t()] | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @revelation_types ["Meccan", "Medinan"]

  schema "surahs" do
    field :chapter_number, :integer
    field :name_ar, :string
    field :name_en, :string
    field :name_bs, :string
    field :revelation_type, :string
    field :verses_count, :integer

    has_many :ayahs, Ayah, foreign_key: :surah_id

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset for creating or updating a Surah.
  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(surah, attrs) do
    surah
    |> cast(attrs, [
      :chapter_number,
      :name_ar,
      :name_en,
      :name_bs,
      :revelation_type,
      :verses_count
    ])
    |> validate_required([:chapter_number, :name_ar, :name_en, :revelation_type, :verses_count])
    |> validate_number(:chapter_number, greater_than: 0, less_than_or_equal_to: 114)
    |> validate_number(:verses_count, greater_than: 0)
    |> validate_inclusion(:revelation_type, @revelation_types)
    |> unique_constraint(:chapter_number)
  end
end
