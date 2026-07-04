defmodule QuranApi.Repo.Migrations.CreateAudio do
  use Ecto.Migration

  def change do
    create table(:audio) do
      add :ayah_id, references(:ayahs, on_delete: :delete_all), null: false
      add :reciter, :string, null: false
      add :audio_url, :string, null: false
      add :duration, :integer

      timestamps(type: :utc_datetime)
    end

    create index(:audio, [:ayah_id])
    create index(:audio, [:reciter])
    create unique_index(:audio, [:ayah_id, :reciter])
  end
end
