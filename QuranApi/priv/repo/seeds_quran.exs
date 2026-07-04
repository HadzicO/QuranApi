# Script for populating the database with sample Quran data.
# Run with: mix run priv/repo/seeds_quran.exs

alias QuranApi.Quran
alias QuranApi.Repo

IO.puts("🌟 Starting Quran API seed data creation...")
IO.puts("=" |> String.duplicate(50))

# Sample Surahs
surahs_data = [
  %{
    chapter_number: 1,
    name_ar: "الفاتحة",
    name_en: "Al-Fatiha",
    name_bs: "El-Fatiha",
    revelation_type: "Meccan",
    verses_count: 7
  },
  %{
    chapter_number: 2,
    name_ar: "البقرة",
    name_en: "Al-Baqarah",
    name_bs: "El-Bekare",
    revelation_type: "Medinan",
    verses_count: 286
  },
  %{
    chapter_number: 112,
    name_ar: "الإخلاص",
    name_en: "Al-Ikhlas",
    name_bs: "El-Ihlas",
    revelation_type: "Meccan",
    verses_count: 4
  }
]

IO.puts("\n📖 Creating surahs...")

surahs =
  Enum.map(surahs_data, fn surah_attrs ->
    {:ok, surah} = Quran.create_surah(surah_attrs)
    IO.puts("  ✓ Created Surah #{surah.chapter_number}: #{surah.name_en}")
    surah
  end)

# Get created surahs
surah_1 = Enum.find(surahs, &(&1.chapter_number == 1))
surah_2 = Enum.find(surahs, &(&1.chapter_number == 2))
surah_112 = Enum.find(surahs, &(&1.chapter_number == 112))

# Sample Ayahs for Al-Fatiha
IO.puts("\n📜 Creating ayahs for Al-Fatiha...")

fatiha_ayahs = [
  %{surah_id: surah_1.id, ayah_number: 1, global_number: 1, arabic_text: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ"},
  %{surah_id: surah_1.id, ayah_number: 2, global_number: 2, arabic_text: "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ"},
  %{surah_id: surah_1.id, ayah_number: 3, global_number: 3, arabic_text: "الرَّحْمَٰنِ الرَّحِيمِ"},
  %{surah_id: surah_1.id, ayah_number: 4, global_number: 4, arabic_text: "مَالِكِ يَوْمِ الدِّينِ"},
  %{surah_id: surah_1.id, ayah_number: 5, global_number: 5, arabic_text: "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ"},
  %{surah_id: surah_1.id, ayah_number: 6, global_number: 6, arabic_text: "اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ"},
  %{surah_id: surah_1.id, ayah_number: 7, global_number: 7, arabic_text: "صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ"}
]

ayahs_1 =
  Enum.map(fatiha_ayahs, fn ayah_attrs ->
    {:ok, ayah} = Quran.create_ayah(ayah_attrs)
    IO.puts("  ✓ Created Ayah #{ayah.ayah_number}")
    ayah
  end)

# Ayatul Kursi
IO.puts("\n📜 Creating Ayatul Kursi (2:255)...")

{:ok, ayatul_kursi} =
  Quran.create_ayah(%{
    surah_id: surah_2.id,
    ayah_number: 255,
    global_number: 255,
    arabic_text: "اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ"
  })

IO.puts("  ✓ Created Ayatul Kursi")

# Surah Al-Ikhlas
IO.puts("\n📜 Creating ayahs for Al-Ikhlas...")

ikhlas_ayahs = [
  %{surah_id: surah_112.id, ayah_number: 1, global_number: 6229, arabic_text: "قُلْ هُوَ اللَّهُ أَحَدٌ"},
  %{surah_id: surah_112.id, ayah_number: 2, global_number: 6230, arabic_text: "اللَّهُ الصَّمَدُ"},
  %{surah_id: surah_112.id, ayah_number: 3, global_number: 6231, arabic_text: "لَمْ يَلِدْ وَلَمْ يُولَدْ"},
  %{surah_id: surah_112.id, ayah_number: 4, global_number: 6232, arabic_text: "وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ"}
]

ayahs_112 =
  Enum.map(ikhlas_ayahs, fn ayah_attrs ->
    {:ok, ayah} = Quran.create_ayah(ayah_attrs)
    IO.puts("  ✓ Created Ayah #{ayah.ayah_number}")
    ayah
  end)

# Translations
IO.puts("\n🌍 Creating translations...")

translations = [
  # Al-Fatiha English
  {Enum.at(ayahs_1, 0), "en", "Sahih International", "In the name of Allah, the Entirely Merciful, the Especially Merciful."},
  {Enum.at(ayahs_1, 1), "en", "Sahih International", "[All] praise is [due] to Allah, Lord of the worlds -"},
  {Enum.at(ayahs_1, 2), "en", "Sahih International", "The Entirely Merciful, the Especially Merciful,"},
  {Enum.at(ayahs_1, 3), "en", "Sahih International", "Sovereign of the Day of Recompense."},
  {Enum.at(ayahs_1, 4), "en", "Sahih International", "It is You we worship and You we ask for help."},
  {Enum.at(ayahs_1, 5), "en", "Sahih International", "Guide us to the straight path -"},
  {Enum.at(ayahs_1, 6), "en", "Sahih International", "The path of those upon whom You have bestowed favor, not of those who have evoked [Your] anger or of those who are astray."},
  # Al-Fatiha Bosnian
  {Enum.at(ayahs_1, 0), "bs", "Besim Korkut", "U ime Allaha, Milostivog, Samilosnog."},
  {Enum.at(ayahs_1, 1), "bs", "Besim Korkut", "Hvala Allahu, Gospodaru svjetova,"},
  {Enum.at(ayahs_1, 2), "bs", "Besim Korkut", "Milostivom, Samilosnom,"},
  {Enum.at(ayahs_1, 3), "bs", "Besim Korkut", "Vladaru Dana sudnjeg!"},
  {Enum.at(ayahs_1, 4), "bs", "Besim Korkut", "Tebi se klanjamo i od Tebe pomoć tražimo,"},
  {Enum.at(ayahs_1, 5), "bs", "Besim Korkut", "uputi nas na Pravi put,"},
  {Enum.at(ayahs_1, 6), "bs", "Besim Korkut", "na put onih kojima si milost Svoju darovao, a ne onih koji su protiv sebe srdžbu izazvali, niti onih koji lutaju."},
  # Ayatul Kursi
  {ayatul_kursi, "en", "Sahih International", "Allah - there is no deity except Him, the Ever-Living, the Sustainer of existence."},
  {ayatul_kursi, "bs", "Besim Korkut", "Allah! Nema boga osim Njega, Živoga, Vječnoga."}
]

Enum.each(translations, fn {ayah, lang, translator, text} ->
  {:ok, _} = Quran.create_translation(%{ayah_id: ayah.id, language_code: lang, translator: translator, text: text})
  IO.puts("  ✓ Added #{lang} translation for Ayah #{ayah.surah_id}:#{ayah.ayah_number}")
end)

# Topics
IO.puts("\n🏷️  Creating topics...")

topics_data = [
  %{slug: "prayer", name: "Prayer"},
  %{slug: "patience", name: "Patience"},
  %{slug: "mercy", name: "Mercy"},
  %{slug: "guidance", name: "Guidance"}
]

topics =
  Enum.map(topics_data, fn topic_attrs ->
    {:ok, topic} = Quran.create_topic(topic_attrs)
    IO.puts("  ✓ Created topic: #{topic.name}")
    topic
  end)

# Associate topics
IO.puts("\n🔗 Associating topics with ayahs...")

guidance_topic = Enum.find(topics, &(&1.slug == "guidance"))
Enum.each(ayahs_1, fn ayah ->
  {:ok, _} = Quran.add_ayah_to_topic(ayah.id, guidance_topic.id)
end)
IO.puts("  ✓ Associated Al-Fatiha with 'guidance'")

IO.puts("\n" <> ("=" |> String.duplicate(50)))
IO.puts("✅ Seed data created successfully!")
IO.puts("\n📊 Summary:")
IO.puts("  • Surahs: #{length(surahs)}")
IO.puts("  • Ayahs: #{Repo.aggregate(QuranApi.Quran.Ayah, :count, :id)}")
IO.puts("  • Translations: #{Repo.aggregate(QuranApi.Quran.Translation, :count, :id)}")
IO.puts("  • Topics: #{length(topics)}")
IO.puts("\n🚀 API ready at http://localhost:4000/api/v1")
IO.puts("\n📖 Try these endpoints:")
IO.puts("  • GET /api/v1/surahs")
IO.puts("  • GET /api/v1/surahs/1/ayahs?language=en")
IO.puts("  • GET /api/v1/random?language=bs")
IO.puts("  • GET /api/v1/daily")
IO.puts("  • GET /api/v1/search?q=Allah&language=en")
