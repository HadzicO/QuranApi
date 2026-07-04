defmodule QuranApiWeb.RandomController do
  @moduledoc """
  Controller for random ayah endpoint.
  """
  use QuranApiWeb, :controller

  alias QuranApi.Quran
  import Ecto.Query

  action_fallback QuranApiWeb.FallbackController

  @doc """
  GET /api/v1/random
  Returns a random ayah with optional filters.
  """
  def show(conn, params) do
    language = params["language"]
    translator = params["translator"]
    topic = params["topic"]
    surah_id = params["surah"]

    preload = build_preload(language, translator)

    opts = [preload: preload]
    opts = if surah_id, do: Keyword.put(opts, :surah_id, surah_id), else: opts
    opts = if topic, do: Keyword.put(opts, :topic_slug, topic), else: opts

    case Quran.get_random_ayah(opts) do
      nil -> {:error, "No ayah found matching the criteria"}
      ayah -> render(conn, :show, ayah: ayah)
    end
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
