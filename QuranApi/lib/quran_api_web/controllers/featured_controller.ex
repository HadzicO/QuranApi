defmodule QuranApiWeb.FeaturedController do
  @moduledoc """
  Controller for featured verses endpoint.
  """
  use QuranApiWeb, :controller

  alias QuranApi.Quran
  import Ecto.Query

  action_fallback QuranApiWeb.FallbackController

  @doc """
  GET /api/v1/featured
  Returns famous/featured verses.
  """
  def index(conn, params) do
    language = params["language"]
    translator = params["translator"]

    preload = build_preload(language, translator)

    ayahs = Quran.get_featured_ayahs(preload: preload)
    render(conn, :index, ayahs: ayahs)
  end

  defp build_preload(nil, nil), do: [:surah]

  defp build_preload(language, nil) do
    [
      :surah,
      translations: from(t in QuranApi.Quran.Translation, where: t.language_code == ^language)
    ]
  end

  defp build_preload(language, translator) do
    [
      :surah,
      translations:
        from(t in QuranApi.Quran.Translation,
          where: t.language_code == ^language and t.translator == ^translator
        )
    ]
  end
end
