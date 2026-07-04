defmodule QuranApi.Repo.Migrations.CreateAyahTopics do
  use Ecto.Migration

  def change do
    create table(:ayah_topics) do
      add :ayah_id, references(:ayahs, on_delete: :delete_all), null: false
      add :topic_id, references(:topics, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:ayah_topics, [:ayah_id])
    create index(:ayah_topics, [:topic_id])
    create unique_index(:ayah_topics, [:ayah_id, :topic_id])
  end
end
