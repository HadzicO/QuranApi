defmodule QuranApiWeb.Router do
  use QuranApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug QuranApiWeb.Plugs.CORS
  end

  scope "/api/v1", QuranApiWeb do
    pipe_through :api

    # Surahs
    get "/surahs", SurahController, :index
    get "/surahs/:id", SurahController, :show
    get "/surahs/:id/ayahs", SurahController, :ayahs

    # Ayahs
    get "/ayahs/:id", AyahController, :show
    get "/surahs/:surah_id/ayahs/:ayah_number", AyahController, :show_by_surah
    post "/ayahs/batch", AyahController, :batch

    # Random & Daily
    get "/random", RandomController, :show
    get "/daily", DailyController, :show

    # Search
    get "/search", SearchController, :index

    # Translations
    get "/translations", TranslationController, :index
    get "/translations/:language", TranslationController, :show
    get "/ayahs/:id/translations", TranslationController, :ayah_translations

    # Tafsir
    get "/ayahs/:id/tafsir", TafsirController, :show
    get "/tafsir/authors", TafsirController, :authors

    # Audio
    get "/reciters", AudioController, :reciters
    get "/audio/:id", AudioController, :show
    get "/surahs/:id/audio", AudioController, :surah_audio

    # Topics
    get "/topics", TopicController, :index
    get "/topics/:slug", TopicController, :show

    # Metadata
    get "/languages", MetadataController, :languages
    get "/stats", MetadataController, :stats
    get "/metadata", MetadataController, :metadata

    # Featured
    get "/featured", FeaturedController, :index

    # Handle OPTIONS preflight requests
    match :options, "/*path", CorsController, :preflight
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:quran_api, :dev_routes) do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
