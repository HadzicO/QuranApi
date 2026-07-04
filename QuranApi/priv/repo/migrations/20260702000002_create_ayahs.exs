defmodule QuranApi.Repo.Migrations.CreateAyahs do
  use Ecto.Migration

  def change do
    create table(:ayahs) do
      add :surah_id, references(:surahs, on_delete: :delete_all), null: false
      add :ayah_number, :integer, null: false
      add :global_number, :integer, null: false
      add :arabic_text, :text, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:ayahs, [:surah_id])
    create unique_index(:ayahs, [:surah_id, :ayah_number])
    create unique_index(:ayahs, [:global_number])
  end
end
