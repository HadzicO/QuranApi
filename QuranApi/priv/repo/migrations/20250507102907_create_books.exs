defmodule QuranApi.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :original_title, :string
      add :author, :string
      add :year_published, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
