defmodule QuranApi.Repo.Migrations.AddChapterIdToQuotes do
  use Ecto.Migration

  def change do
    alter table(:quotes) do
      add :chapter_id, references(:chapters, on_delete: :delete_all)
    end

    create index(:quotes, [:chapter_id])
  end
end
