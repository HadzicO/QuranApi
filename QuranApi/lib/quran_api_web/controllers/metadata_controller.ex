defmodule QuranApiWeb.MetadataController do
  @moduledoc """
  Controller for metadata and statistics endpoints.
  """
  use QuranApiWeb, :controller

  alias QuranApi.{Quran, Cache}

  action_fallback QuranApiWeb.FallbackController

  # Cache for 1 hour (3600 seconds)
  @cache_ttl 3_600

  @doc """
  GET /api/v1/languages
  Lists all available languages.
  """
  def languages(conn, _params) do
    languages =
      Cache.get_or_compute(:languages, @cache_ttl, fn ->
        Quran.list_languages()
      end)

    render(conn, :languages, languages: languages)
  end

  @doc """
  GET /api/v1/stats
  Returns statistics about the Quran database.
  """
  def stats(conn, _params) do
    stats =
      Cache.get_or_compute(Cache.stats_key(), @cache_ttl, fn ->
        Quran.get_stats()
      end)

    render(conn, :stats, stats: stats)
  end

  @doc """
  GET /api/v1/metadata
  Returns metadata about the API.
  """
  def metadata(conn, _params) do
    metadata =
      Cache.get_or_compute(Cache.metadata_key(), @cache_ttl, fn ->
        Quran.get_metadata()
      end)

    render(conn, :metadata, metadata: metadata)
  end
end
