defmodule QuranApi.Repo.Migrations.CreateQuoteTranslations do
  use Ecto.Migration

  def change do
    create table(:quote_translations) do
      add :language_code, :string
      add :content, :text
      add :quote_id, references(:quotes, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:quote_translations, [:quote_id])
  end
end
