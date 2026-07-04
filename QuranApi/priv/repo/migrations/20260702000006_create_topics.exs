defmodule QuranApi.Repo.Migrations.CreateTopics do
  use Ecto.Migration

  def change do
    create table(:topics) do
      add :slug, :string, null: false
      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:topics, [:slug])
  end
end
