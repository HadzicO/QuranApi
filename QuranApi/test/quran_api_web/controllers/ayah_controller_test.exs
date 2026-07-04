defmodule QuranApiWeb.AyahControllerTest do
  use QuranApiWeb.ConnCase, async: true

  alias QuranApi.Quran.{Surah, Ayah}

  setup do
    surah =
      Repo.insert!(%Surah{
        chapter_number: 2,
        name_ar: "البقرة",
        name_en: "Al-Baqarah",
        revelation_type: "Medinan",
        verses_count: 286
      })

    ayah =
      Repo.insert!(%Ayah{
        surah_id: surah.id,
        ayah_number: 255,
        global_number: 255,
        arabic_text: "اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ"
      })

    {:ok, surah: surah, ayah: ayah}
  end

  describe "GET /api/v1/ayahs/:id" do
    test "returns ayah when id is valid", %{conn: conn, ayah: ayah} do
      conn = get(conn, ~p"/api/v1/ayahs/#{ayah.id}")
      assert %{"data" => data} = json_response(conn, 200)
      assert data["id"] == ayah.id
      assert data["ayah_number"] == 255
    end

    test "returns 404 when id is invalid", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/ayahs/999999")
      assert %{"error" => _} = json_response(conn, 404)
    end
  end

  describe "GET /api/v1/surahs/:surah_id/ayahs/:ayah_number" do
    test "returns ayah by surah and number", %{conn: conn, surah: surah, ayah: ayah} do
      conn = get(conn, ~p"/api/v1/surahs/#{surah.id}/ayahs/255")
      assert %{"data" => data} = json_response(conn, 200)
      assert data["id"] == ayah.id
      assert data["ayah_number"] == 255
    end

    test "returns 404 when ayah does not exist", %{conn: conn, surah: surah} do
      conn = get(conn, ~p"/api/v1/surahs/#{surah.id}/ayahs/9999")
      assert %{"error" => _} = json_response(conn, 404)
    end
  end

  describe "POST /api/v1/ayahs/batch" do
    test "returns multiple ayahs by references", %{conn: conn, surah: surah, ayah: ayah} do
      conn = post(conn, ~p"/api/v1/ayahs/batch", ["2:255"])
      assert %{"data" => ayahs} = json_response(conn, 200)
      assert length(ayahs) == 1
    end

    test "returns error for invalid reference format", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/ayahs/batch", ["invalid"])
      assert %{"error" => _} = json_response(conn, 400)
    end

    test "returns error for non-array input", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/ayahs/batch", %{"data" => "invalid"})
      assert %{"error" => _} = json_response(conn, 400)
    end
  end
end
