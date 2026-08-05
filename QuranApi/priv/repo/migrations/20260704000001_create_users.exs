defmodule QuranApi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :password_hash, :string, null: false
      add :role, :string, null: false, default: "editor"
      add :status, :string, null: false, default: "active"
      add :first_name, :string
      add :last_name, :string
      add :last_login_at, :utc_datetime
      add :last_login_ip, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
    create index(:users, [:role])
    create index(:users, [:status])
  end
end
