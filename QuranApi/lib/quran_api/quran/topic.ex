defmodule QuranApi.Quran.Topic do
  @moduledoc """
  Schema for Topics (thematic categories for Ayahs).
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias QuranApi.Quran.AyahTopic

  @type t :: %__MODULE__{
          id: integer(),
          slug: String.t(),
          name: String.t(),
          ayah_topics: [AyahTopic.t()] | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "topics" do
    field :slug, :string
    field :name, :string

    has_many :ayah_topics, AyahTopic, foreign_key: :topic_id
    has_many :ayahs, through: [:ayah_topics, :ayah]

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset for creating or updating a Topic.
  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(topic, attrs) do
    topic
    |> cast(attrs, [:slug, :name])
    |> validate_required([:slug, :name])
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/)
    |> unique_constraint(:slug)
  end
end
