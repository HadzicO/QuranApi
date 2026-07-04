defmodule QuranApi.QuranTest do
  use QuranApi.DataCase, async: true

  alias QuranApi.Quran
  alias QuranApi.Quran.{Surah, Ayah, Translation, Topic}

  describe "surahs" do
    @valid_surah_attrs %{
      chapter_number: 1,
      name_ar: "الفاتحة",
      name_en: "Al-Fatiha",
      name_bs: "El-Fatiha",
      revelation_type: "Meccan",
      verses_count: 7
    }

    test "list_surahs/1 returns all surahs" do
      surah = insert(:surah)
      assert length(Quran.list_surahs()) >= 1
    end

    test "get_surah/1 returns the surah with given id" do
      surah = insert(:surah)
      assert Quran.get_surah(surah.id).id == surah.id
    end

    test "get_surah_by_number/1 returns the surah with given chapter number" do
      surah = insert(:surah, chapter_number: 42)
      assert Quran.get_surah_by_number(42).id == surah.id
    end

    test "create_surah/1 with valid data creates a surah" do
      assert {:ok, %Surah{} = surah} = Quran.create_surah(@valid_surah_attrs)
      assert surah.chapter_number == 1
      assert surah.name_ar == "الفاتحة"
      assert surah.name_en == "Al-Fatiha"
    end

    test "create_surah/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Quran.create_surah(%{})
    end
  end

  describe "ayahs" do
    setup do
      surah = insert(:surah)
      {:ok, surah: surah}
    end

    test "list_ayahs_by_surah/2 returns all ayahs for a surah", %{surah: surah} do
      ayah = insert(:ayah, surah: surah)
      ayahs = Quran.list_ayahs_by_surah(surah.id)
      assert length(ayahs) >= 1
    end

    test "get_ayah/2 returns the ayah with given id", %{surah: surah} do
      ayah = insert(:ayah, surah: surah)
      assert Quran.get_ayah(ayah.id).id == ayah.id
    end

    test "get_ayah_by_surah_and_number/3 returns the ayah", %{surah: surah} do
      ayah = insert(:ayah, surah: surah, ayah_number: 5)
      result = Quran.get_ayah_by_surah_and_number(surah.id, 5)
      assert result.id == ayah.id
    end

    test "parse_ayah_reference/1 parses valid reference" do
      assert {:ok, 2, 255} = Quran.parse_ayah_reference("2:255")
      assert {:ok, 112, 1} = Quran.parse_ayah_reference("112:1")
    end

    test "parse_ayah_reference/1 returns error for invalid reference" do
      assert {:error, _} = Quran.parse_ayah_reference("invalid")
      assert {:error, _} = Quran.parse_ayah_reference("2-255")
    end

    test "get_random_ayah/1 returns a random ayah", %{surah: surah} do
      insert(:ayah, surah: surah)
      insert(:ayah, surah: surah, ayah_number: 2, global_number: 2)
      assert %Ayah{} = Quran.get_random_ayah()
    end

    test "get_daily_ayah/1 returns the same ayah for the same day", %{surah: surah} do
      insert(:ayah, surah: surah)
      ayah1 = Quran.get_daily_ayah()
      ayah2 = Quran.get_daily_ayah()
      assert ayah1.id == ayah2.id
    end
  end

  describe "translations" do
    setup do
      surah = insert(:surah)
      ayah = insert(:ayah, surah: surah)
      {:ok, surah: surah, ayah: ayah}
    end

    test "get_ayah_translations/2 returns translations for an ayah", %{ayah: ayah} do
      translation = insert(:translation, ayah: ayah)
      translations = Quran.get_ayah_translations(ayah.id)
      assert length(translations) >= 1
    end

    test "list_languages/0 returns available languages", %{ayah: ayah} do
      insert(:translation, ayah: ayah, language_code: "en")
      languages = Quran.list_languages()
      assert length(languages) >= 1
    end

    test "list_translators/0 returns available translators", %{ayah: ayah} do
      insert(:translation, ayah: ayah)
      translators = Quran.list_translators()
      assert length(translators) >= 1
    end
  end

  describe "topics" do
    setup do
      surah = insert(:surah)
      ayah = insert(:ayah, surah: surah)
      {:ok, surah: surah, ayah: ayah}
    end

    test "list_topics/0 returns all topics" do
      topic = insert(:topic)
      topics = Quran.list_topics()
      assert length(topics) >= 1
    end

    test "get_topic_by_slug/1 returns topic by slug" do
      topic = insert(:topic, slug: "patience")
      assert Quran.get_topic_by_slug("patience").id == topic.id
    end

    test "get_ayahs_by_topic/2 returns ayahs for a topic", %{ayah: ayah} do
      topic = insert(:topic)
      insert(:ayah_topic, ayah: ayah, topic: topic)
      ayahs = Quran.get_ayahs_by_topic(topic.slug)
      assert length(ayahs) >= 1
    end
  end

  describe "search" do
    setup do
      surah = insert(:surah)
      ayah = insert(:ayah, surah: surah, arabic_text: "بِسْمِ اللَّهِ")
      translation = insert(:translation, ayah: ayah, text: "In the name of Allah")
      {:ok, surah: surah, ayah: ayah, translation: translation}
    end

    test "search/1 finds ayahs by Arabic text", %{ayah: ayah} do
      result = Quran.search(q: "اللَّهِ", page: 1, per_page: 10)
      assert result.total >= 1
    end

    test "search/1 finds ayahs by translation", %{translation: translation} do
      result = Quran.search(q: "Allah", language: "en", page: 1, per_page: 10)
      assert result.total >= 1
    end
  end

  # Factory helper functions
  defp insert(schema, attrs \\ %{}) do
    case schema do
      :surah ->
        default_attrs = %{
          chapter_number: :rand.uniform(114),
          name_ar: "سورة",
          name_en: "Surah",
          revelation_type: "Meccan",
          verses_count: 10
        }

        %Surah{}
        |> Surah.changeset(Map.merge(default_attrs, Map.new(attrs)))
        |> Repo.insert!()

      :ayah ->
        default_attrs = %{
          ayah_number: 1,
          global_number: :rand.uniform(6236),
          arabic_text: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ"
        }

        surah = attrs[:surah] || insert(:surah)
        attrs = Map.delete(attrs, :surah)

        %Ayah{}
        |> Ayah.changeset(
          Map.merge(default_attrs, Map.merge(%{surah_id: surah.id}, Map.new(attrs)))
        )
        |> Repo.insert!()

      :translation ->
        default_attrs = %{
          language_code: "en",
          translator: "Test Translator",
          text: "Test translation text"
        }

        ayah = attrs[:ayah] || insert(:ayah)
        attrs = Map.delete(attrs, :ayah)

        %Translation{}
        |> Translation.changeset(
          Map.merge(default_attrs, Map.merge(%{ayah_id: ayah.id}, Map.new(attrs)))
        )
        |> Repo.insert!()

      :topic ->
        default_attrs = %{
          slug: "test-topic-#{:rand.uniform(10000)}",
          name: "Test Topic"
        }

        %Topic{}
        |> Topic.changeset(Map.merge(default_attrs, Map.new(attrs)))
        |> Repo.insert!()

      :ayah_topic ->
        ayah = attrs[:ayah] || insert(:ayah)
        topic = attrs[:topic] || insert(:topic)

        %QuranApi.Quran.AyahTopic{}
        |> QuranApi.Quran.AyahTopic.changeset(%{ayah_id: ayah.id, topic_id: topic.id})
        |> Repo.insert!()
    end
  end
end
