defmodule QuranApi.Quran.Audio do
  @moduledoc """
  Schema for Ayah audio recitations.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias QuranApi.Quran.Ayah

  @type t :: %__MODULE__{
          id: integer(),
          ayah_id: integer(),
          reciter: String.t(),
          audio_url: String.t(),
          duration: integer() | nil,
          ayah: Ayah.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "audio" do
    field :reciter, :string
    field :audio_url, :string
    field :duration, :integer

    belongs_to :ayah, Ayah

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset for creating or updating Audio.
  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(audio, attrs) do
    audio
    |> cast(attrs, [:ayah_id, :reciter, :audio_url, :duration])
    |> validate_required([:ayah_id, :reciter, :audio_url])
    |> validate_number(:duration, greater_than: 0)
    |> foreign_key_constraint(:ayah_id)
    |> unique_constraint([:ayah_id, :reciter])
  end
end
