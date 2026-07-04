defmodule QuranApiWeb.TopicController do
  @moduledoc """
  Controller for Topic endpoints.
  """
  use QuranApiWeb, :controller

  alias QuranApi.Quran
  import Ecto.Query

  action_fallback QuranApiWeb.FallbackController

  @doc """
  GET /api/v1/topics
  Lists all topics.
  """
  def index(conn, _params) do
    topics = Quran.list_topics()
    render(conn, :index, topics: topics)
  end

  @doc """
  GET /api/v1/topics/:slug
  Gets all ayahs for a specific topic.
  """
  def show(conn, %{"slug" => slug} = params) do
    case Quran.get_topic_by_slug(slug) do
      nil ->
        {:error, :not_found}

      topic ->
        limit = parse_int(params["limit"], 100)
        offset = parse_int(params["offset"], 0)
        language = params["language"]
        translator = params["translator"]

        preload = build_preload(language, translator)

        ayahs = Quran.get_ayahs_by_topic(slug, limit: limit, offset: offset, preload: preload)
        render(conn, :show, topic: topic, ayahs: ayahs)
    end
  end

  defp parse_int(nil, default), do: default

  defp parse_int(value, default) do
    case Integer.parse(value) do
      {int, ""} -> int
      _ -> default
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
