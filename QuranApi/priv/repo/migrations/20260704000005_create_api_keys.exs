defmodule QuranApi.Repo.Migrations.CreateApiKeys do
  use Ecto.Migration

  def change do
    create table(:api_keys) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :key_hash, :string, null: false
      add :name, :string, null: false
      add :description, :text
      add :status, :string, null: false, default: "active"
      add :last_used_at, :utc_datetime
      add :last_used_ip, :string
      add :expires_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:api_keys, [:key_hash])
    create index(:api_keys, [:user_id])
    create index(:api_keys, [:status])
  end
end
