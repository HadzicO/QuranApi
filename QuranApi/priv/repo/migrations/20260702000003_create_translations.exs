defmodule QuranApi.Repo.Migrations.CreateTranslations do
  use Ecto.Migration

  def change do
    create table(:translations) do
      add :ayah_id, references(:ayahs, on_delete: :delete_all), null: false
      add :language_code, :string, null: false
      add :translator, :string, null: false
      add :text, :text, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:translations, [:ayah_id])
    create index(:translations, [:language_code])
    create index(:translations, [:translator])
    create unique_index(:translations, [:ayah_id, :language_code, :translator])
  end
end
