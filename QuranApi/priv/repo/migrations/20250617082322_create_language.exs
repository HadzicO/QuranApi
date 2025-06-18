defmodule QuranApi.Repo.Migrations.CreateLanguage do
  use Ecto.Migration

  def change do
    create table(:language) do
      add :language_name, :string
      add :language_code, :string

      timestamps(type: :utc_datetime)
    end
  end
end
