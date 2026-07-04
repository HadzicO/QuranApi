defmodule QuranApi.Repo.Migrations.CreateTafsirs do
  use Ecto.Migration

  def change do
    create table(:tafsirs) do
      add :ayah_id, references(:ayahs, on_delete: :delete_all), null: false
      add :author, :string, null: false
      add :language_code, :string, null: false
      add :text, :text, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:tafsirs, [:ayah_id])
    create index(:tafsirs, [:author])
    create index(:tafsirs, [:language_code])
    create unique_index(:tafsirs, [:ayah_id, :author, :language_code])
  end
end
