defmodule QuranApi.Repo.Migrations.CreateChapters do
  use Ecto.Migration

  def change do
    create table(:chapters) do
      add :name, :string
      add :number, :integer
      add :number_of_quote, :integer
      add :publication, :string
      add :book_id, references(:books, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:chapters, [:book_id])
  end
end
