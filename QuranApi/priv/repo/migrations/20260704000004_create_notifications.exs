defmodule QuranApi.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :type, :string, null: false
      add :title, :string, null: false
      add :message, :text, null: false
      add :related_entity_type, :string
      add :related_entity_id, :integer
      add :read, :boolean, default: false, null: false
      add :read_at, :utc_datetime

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:notifications, [:user_id])
    create index(:notifications, [:read])
    create index(:notifications, [:type])
    create index(:notifications, [:inserted_at])
  end
end
