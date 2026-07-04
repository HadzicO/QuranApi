defmodule QuranApi.Repo.Migrations.CreateSurahs do
  use Ecto.Migration

  def change do
    create table(:surahs) do
      add :chapter_number, :integer, null: false
      add :name_ar, :string, null: false
      add :name_en, :string, null: false
      add :name_bs, :string
      add :revelation_type, :string, null: false
      add :verses_count, :integer, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:surahs, [:chapter_number])
    create index(:surahs, [:revelation_type])
  end
end
