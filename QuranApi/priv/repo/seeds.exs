alias QuranApi.Repo
alias QuranApi.Books.Book
alias QuranApi.Quotes.{Quote, QuoteTranslation}

quran =
  %Book{
    original_title: "Al-Qur'an",
    author: "Allah (via revelation to Prophet Muhammad)",
    year_published: 610  # Approximate, first revelation
  }
  |> Repo.insert!()

quotes = [
  {"بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ", "U ime Allaha, Milostivog, Samilosnog."},
  {"الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ", "Hvala Allahu, Gospodaru svjetova,"},
  {"الرَّحْمَٰنِ الرَّحِيمِ", "Milostivom, Samilosnom,"},
  {"مَالِكِ يَوْمِ الدِّينِ", "Vladaru Dana sudnjega."},
  {"إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ", "Tebe obožavamo i od Tebe pomoć tražimo."},
  {"اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ", "Uputi nas na Pravi put,"},
  {"صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ",
   "Put onih kojima si milost Svoju darovao, a ne onih na koje se srdžba Tvoja obrušila, niti onih koji su zalutali."}
]

Enum.with_index(quotes, 1)
|> Enum.each(fn {{ar, bs}, index} ->
  quote =
    %Quote{
      book_id: quran.id,
      quote_order: index,
      content: ar
    }
    |> Repo.insert!()

  %QuoteTranslation{
    quote_id: quote.id,
    language_code: "bs",
    content: bs
  }
  |> Repo.insert!()
end)
