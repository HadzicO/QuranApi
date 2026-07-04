defmodule QuranApiWeb.SearchController do
  @moduledoc """
  Controller for search endpoint.
  """
  use QuranApiWeb, :controller

  alias QuranApi.Quran

  action_fallback QuranApiWeb.FallbackController

  @doc """
  GET /api/v1/search
  Searches for ayahs and translations.
  """
  def index(conn, params) do
    query = params["q"]

    if is_nil(query) or String.trim(query) == "" do
      {:error, "Search query parameter 'q' is required"}
    else
      opts = [
        q: query,
        language: params["language"],
        translator: params["translator"],
        surah: parse_int(params["surah"], nil),
        topic: params["topic"],
        revelation: params["revelation"],
        page: parse_int(params["page"], 1),
        per_page: parse_int(params["per_page"], 20)
      ]

      result = Quran.search(opts)
      render(conn, :index, result: result)
    end
  end

  defp parse_int(nil, default), do: default

  defp parse_int(value, default) do
    case Integer.parse(value) do
      {int, ""} -> int
      _ -> default
    end
  end
end
