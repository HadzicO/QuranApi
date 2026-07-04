defmodule QuranApi.Quran.AyahTopic do
  @moduledoc """
  Join schema for many-to-many relationship between Ayahs and Topics.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias QuranApi.Quran.{Ayah, Topic}

  @type t :: %__MODULE__{
          id: integer(),
          ayah_id: integer(),
          topic_id: integer(),
          ayah: Ayah.t() | Ecto.Association.NotLoaded.t(),
          topic: Topic.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "ayah_topics" do
    belongs_to :ayah, Ayah
    belongs_to :topic, Topic

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset for creating or updating an AyahTopic association.
  """
  @spec changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def changeset(ayah_topic, attrs) do
    ayah_topic
    |> cast(attrs, [:ayah_id, :topic_id])
    |> validate_required([:ayah_id, :topic_id])
    |> foreign_key_constraint(:ayah_id)
    |> foreign_key_constraint(:topic_id)
    |> unique_constraint([:ayah_id, :topic_id])
  end
end
