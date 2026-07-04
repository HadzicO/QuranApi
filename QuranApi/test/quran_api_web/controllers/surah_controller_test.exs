defmodule QuranApiWeb.SurahControllerTest do
  use QuranApiWeb.ConnCase, async: true

  alias QuranApi.Quran.Surah

  setup do
    surah =
      Repo.insert!(%Surah{
        chapter_number: 1,
        name_ar: "الفاتحة",
        name_en: "Al-Fatiha",
        name_bs: "El-Fatiha",
        revelation_type: "Meccan",
        verses_count: 7
      })

    {:ok, surah: surah}
  end

  describe "GET /api/v1/surahs" do
    test "lists all surahs", %{conn: conn, surah: surah} do
      conn = get(conn, ~p"/api/v1/surahs")
      assert %{"data" => surahs} = json_response(conn, 200)
      assert length(surahs) >= 1
    end

    test "supports pagination", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/surahs?limit=5&offset=0")
      assert %{"data" => surahs} = json_response(conn, 200)
      assert length(surahs) <= 5
    end
  end

  describe "GET /api/v1/surahs/:id" do
    test "returns surah when id is valid", %{conn: conn, surah: surah} do
      conn = get(conn, ~p"/api/v1/surahs/#{surah.id}")
      assert %{"data" => data} = json_response(conn, 200)
      assert data["id"] == surah.id
      assert data["name_en"] == "Al-Fatiha"
    end

    test "returns 404 when id is invalid", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/surahs/999999")
      assert %{"error" => _} = json_response(conn, 404)
    end
  end

  describe "GET /api/v1/surahs/:id/ayahs" do
    test "returns ayahs for a surah", %{conn: conn, surah: surah} do
      ayah =
        Repo.insert!(%QuranApi.Quran.Ayah{
          surah_id: surah.id,
          ayah_number: 1,
          global_number: 1,
          arabic_text: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ"
        })

      conn = get(conn, ~p"/api/v1/surahs/#{surah.id}/ayahs")
      assert %{"data" => %{"surah" => _, "ayahs" => ayahs}} = json_response(conn, 200)
      assert length(ayahs) >= 1
    end

    test "returns 404 when surah does not exist", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/surahs/999999/ayahs")
      assert %{"error" => _} = json_response(conn, 404)
    end
  end
end
