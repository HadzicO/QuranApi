defmodule QuranApiWeb.TranslationController do
  @moduledoc """
  Controller for Translation endpoints.
  """
  use QuranApiWeb, :controller

  alias QuranApi.Quran

  action_fallback QuranApiWeb.FallbackController

  @doc """
  GET /api/v1/translations
  Lists all available translators grouped by language.
  """
  def index(conn, _params) do
    translators = Quran.list_translators()
    render(conn, :index, translators: translators)
  end

  @doc """
  GET /api/v1/translations/:language
  Lists all translations for a specific language.
  """
  def show(conn, %{"language" => language}) do
    translations = Quran.list_translations_by_language(language)
    render(conn, :show, translations: translations)
  end

  @doc """
  GET /api/v1/ayahs/:id/translations
  Gets all translations for a specific ayah.
  """
  def ayah_translations(conn, %{"id" => ayah_id} = params) do
    language = params["language"]
    translator = params["translator"]

    opts = []
    opts = if language, do: Keyword.put(opts, :language_code, language), else: opts
    opts = if translator, do: Keyword.put(opts, :translator, translator), else: opts

    translations = Quran.get_ayah_translations(ayah_id, opts)
    render(conn, :translations, translations: translations)
  end
end
