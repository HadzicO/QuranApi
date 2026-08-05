defmodule QuranApi.Repo.Migrations.CreateAuditLogs do
  use Ecto.Migration

  def change do
    create table(:audit_logs) do
      add :user_id, references(:users, on_delete: :nilify_all)
      add :action, :string, null: false
      add :entity_type, :string, null: false
      add :entity_id, :integer
      add :changes, :map
      add :ip_address, :string
      add :user_agent, :string

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:audit_logs, [:user_id])
    create index(:audit_logs, [:entity_type, :entity_id])
    create index(:audit_logs, [:action])
    create index(:audit_logs, [:inserted_at])
  end
end
