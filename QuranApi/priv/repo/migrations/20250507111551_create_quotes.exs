defmodule QuranApi.Repo.Migrations.CreateQuotes do
  use Ecto.Migration

  def change do
    create table(:quotes) do
      add :quote_order, :integer
      add :content, :text
      add :book_id, references(:books, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:quotes, [:book_id])
  end
end
