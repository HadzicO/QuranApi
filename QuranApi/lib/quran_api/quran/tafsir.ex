defmodule QuranApi.Quran.Tafsir do
  @moduledoc """
  Schema for Ayah tafsir (exegesis/commentary).
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias QuranApi.Quran.Ayah

  @type t :: %__MODULE__{
          id: integer(),
          ayah_id: integer(),
          author: String.t(),
          language_code: String.t(),
          text: String.t(),
          ayah: Ayah.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "tafsirs" do
    field :author, :string
    field :language_code, :string
    field :text, :string

    belongs_to :ayah, Ayah

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset for creating or updating a Tafsir.
  """
  @spec changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def changeset(tafsir, attrs) do
    tafsir
    |> cast(attrs, [:ayah_id, :author, :language_code, :text])
    |> validate_required([:ayah_id, :author, :language_code, :text])
    |> validate_length(:language_code, is: 2)
    |> foreign_key_constraint(:ayah_id)
    |> unique_constraint([:ayah_id, :author, :language_code])
  end
end
