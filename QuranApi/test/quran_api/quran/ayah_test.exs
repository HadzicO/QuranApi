defmodule QuranApi.Quran.AyahTest do
  use QuranApi.DataCase, async: true

  alias QuranApi.Quran.{Ayah, Surah}

  setup do
    surah =
      Repo.insert!(%Surah{
        chapter_number: 1,
        name_ar: "الفاتحة",
        name_en: "Al-Fatiha",
        revelation_type: "Meccan",
        verses_count: 7
      })

    {:ok, surah: surah}
  end

  describe "changeset/2" do
    test "with valid attributes", %{surah: surah} do
      attrs = %{
        surah_id: surah.id,
        ayah_number: 1,
        global_number: 1,
        arabic_text: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ"
      }

      changeset = Ayah.changeset(%Ayah{}, attrs)
      assert changeset.valid?
    end

    test "requires all fields", %{surah: surah} do
      changeset = Ayah.changeset(%Ayah{}, %{})
      refute changeset.valid?

      assert %{
               surah_id: ["can't be blank"],
               ayah_number: ["can't be blank"],
               global_number: ["can't be blank"],
               arabic_text: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates ayah_number is positive", %{surah: surah} do
      attrs = %{
        surah_id: surah.id,
        ayah_number: 0,
        global_number: 1,
        arabic_text: "text"
      }

      changeset = Ayah.changeset(%Ayah{}, attrs)
      assert %{ayah_number: ["must be greater than 0"]} = errors_on(changeset)
    end

    test "validates global_number is between 1 and 6236", %{surah: surah} do
      attrs = %{
        surah_id: surah.id,
        ayah_number: 1,
        global_number: 0,
        arabic_text: "text"
      }

      changeset = Ayah.changeset(%Ayah{}, attrs)
      assert %{global_number: ["must be greater than 0"]} = errors_on(changeset)

      attrs = %{
        surah_id: surah.id,
        ayah_number: 1,
        global_number: 6237,
        arabic_text: "text"
      }

      changeset = Ayah.changeset(%Ayah{}, attrs)
      assert %{global_number: ["must be less than or equal to 6236"]} = errors_on(changeset)
    end
  end
end
