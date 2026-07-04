defmodule QuranApiWeb.DailyController do
  @moduledoc """
  Controller for daily verse endpoint.
  """
  use QuranApiWeb, :controller

  alias QuranApi.{Cache, Quran}
  import Ecto.Query

  action_fallback QuranApiWeb.FallbackController

  # Cache for 24 hours (86400 seconds)
  @cache_ttl 86_400

  @doc """
  GET /api/v1/daily
  Returns the daily ayah (same for all users on the same UTC day).
  """
  def show(conn, params) do
    language = params["language"]
    translator = params["translator"]

    preload = build_preload(language, translator)

    cache_key = build_cache_key(language, translator)

    ayah =
      Cache.get_or_compute(cache_key, @cache_ttl, fn ->
        Quran.get_daily_ayah(preload: preload)
      end)

    case ayah do
      nil -> {:error, "Daily ayah not available"}
      ayah -> render(conn, :show, ayah: ayah)
    end
  end

  defp build_cache_key(nil, nil), do: :daily_verse_default

  defp build_cache_key(language, nil),
    do: String.to_atom("daily_verse_#{language}")

  defp build_cache_key(language, translator),
    do: String.to_atom("daily_verse_#{language}_#{translator}")

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
