defmodule QuranApi.Repo.Migrations.CreateRevisions do
  use Ecto.Migration

  def change do
    create table(:revisions) do
      add :user_id, references(:users, on_delete: :nilify_all)
      add :entity_type, :string, null: false
      add :entity_id, :integer, null: false
      add :status, :string, null: false, default: "draft"
      add :old_value, :map
      add :new_value, :map, null: false
      add :reason, :text
      add :reviewed_by_id, references(:users, on_delete: :nilify_all)
      add :reviewed_at, :utc_datetime
      add :review_notes, :text
      add :published_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:revisions, [:user_id])
    create index(:revisions, [:entity_type, :entity_id])
    create index(:revisions, [:status])
    create index(:revisions, [:reviewed_by_id])
  end
end
