defmodule QuranApi.Repo.Migrations.CreateQuotes do
  use Ecto.Migration

  def change do
    create table(:quotes) do
      add :quote_order, :integer
      add :content, :text

      timestamps(type: :utc_datetime)
    end
  end
end
