defmodule QuranApi.Quran.SurahTest do
  use QuranApi.DataCase, async: true

  alias QuranApi.Quran.Surah

  @valid_attrs %{
    chapter_number: 1,
    name_ar: "الفاتحة",
    name_en: "Al-Fatiha",
    name_bs: "El-Fatiha",
    revelation_type: "Meccan",
    verses_count: 7
  }

  @invalid_attrs %{}

  describe "changeset/2" do
    test "with valid attributes" do
      changeset = Surah.changeset(%Surah{}, @valid_attrs)
      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = Surah.changeset(%Surah{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "requires chapter_number" do
      attrs = Map.delete(@valid_attrs, :chapter_number)
      changeset = Surah.changeset(%Surah{}, attrs)
      assert %{chapter_number: ["can't be blank"]} = errors_on(changeset)
    end

    test "requires name_ar" do
      attrs = Map.delete(@valid_attrs, :name_ar)
      changeset = Surah.changeset(%Surah{}, attrs)
      assert %{name_ar: ["can't be blank"]} = errors_on(changeset)
    end

    test "requires name_en" do
      attrs = Map.delete(@valid_attrs, :name_en)
      changeset = Surah.changeset(%Surah{}, attrs)
      assert %{name_en: ["can't be blank"]} = errors_on(changeset)
    end

    test "validates chapter_number is between 1 and 114" do
      invalid_attrs = Map.put(@valid_attrs, :chapter_number, 0)
      changeset = Surah.changeset(%Surah{}, invalid_attrs)
      assert %{chapter_number: ["must be greater than 0"]} = errors_on(changeset)

      invalid_attrs = Map.put(@valid_attrs, :chapter_number, 115)
      changeset = Surah.changeset(%Surah{}, invalid_attrs)
      assert %{chapter_number: ["must be less than or equal to 114"]} = errors_on(changeset)
    end

    test "validates revelation_type is Meccan or Medinan" do
      invalid_attrs = Map.put(@valid_attrs, :revelation_type, "Unknown")
      changeset = Surah.changeset(%Surah{}, invalid_attrs)
      assert %{revelation_type: ["is invalid"]} = errors_on(changeset)
    end

    test "validates verses_count is positive" do
      invalid_attrs = Map.put(@valid_attrs, :verses_count, 0)
      changeset = Surah.changeset(%Surah{}, invalid_attrs)
      assert %{verses_count: ["must be greater than 0"]} = errors_on(changeset)
    end
  end
end
