defmodule QuranApiWeb.SearchControllerTest do
  use QuranApiWeb.ConnCase, async: true

  alias QuranApi.Quran.{Surah, Ayah, Translation}

  setup do
    surah =
      Repo.insert!(%Surah{
        chapter_number: 1,
        name_ar: "الفاتحة",
        name_en: "Al-Fatiha",
        revelation_type: "Meccan",
        verses_count: 7
      })

    ayah =
      Repo.insert!(%Ayah{
        surah_id: surah.id,
        ayah_number: 1,
        global_number: 1,
        arabic_text: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ"
      })

    translation =
      Repo.insert!(%Translation{
        ayah_id: ayah.id,
        language_code: "en",
        translator: "Sahih International",
        text: "In the name of Allah, the Entirely Merciful, the Especially Merciful."
      })

    {:ok, surah: surah, ayah: ayah, translation: translation}
  end

  describe "GET /api/v1/search" do
    test "searches by query parameter", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/search?q=Allah")
      assert %{"data" => results, "meta" => meta} = json_response(conn, 200)
      assert is_list(results)
      assert meta["total"] >= 0
    end

    test "requires query parameter", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/search")
      assert %{"error" => _} = json_response(conn, 400)
    end

    test "supports language filter", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/search?q=Merciful&language=en")
      assert %{"data" => _results, "meta" => _meta} = json_response(conn, 200)
    end

    test "supports pagination", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/search?q=Allah&page=1&per_page=5")
      assert %{"data" => results, "meta" => meta} = json_response(conn, 200)
      assert meta["page"] == 1
      assert meta["per_page"] == 5
    end
  end
end
