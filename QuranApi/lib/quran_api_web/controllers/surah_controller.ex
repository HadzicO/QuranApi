defmodule QuranApiWeb.SurahController do
  @moduledoc """
  Controller for Surah endpoints.
  """
  use QuranApiWeb, :controller

  alias QuranApi.Quran

  action_fallback QuranApiWeb.FallbackController

  @doc """
  GET /api/v1/surahs
  Lists all surahs with optional pagination.
  """
  def index(conn, params) do
    limit = parse_int(params["limit"], 114)
    offset = parse_int(params["offset"], 0)
    order_by = parse_atom(params["order_by"], :chapter_number)
    order = parse_atom(params["order"], :asc)

    surahs = Quran.list_surahs(limit: limit, offset: offset, order_by: order_by, order: order)

    render(conn, :index, surahs: surahs)
  end

  @doc """
  GET /api/v1/surahs/:id
  Gets a single surah by ID.
  """
  def show(conn, %{"id" => id}) do
    case Quran.get_surah(id) do
      nil -> {:error, :not_found}
      surah -> render(conn, :show, surah: surah)
    end
  end

  @doc """
  GET /api/v1/surahs/:id/ayahs
  Gets all ayahs for a surah.
  """
  def ayahs(conn, %{"id" => id} = params) do
    case Quran.get_surah(id) do
      nil ->
        {:error, :not_found}

      surah ->
        limit = parse_int(params["limit"], 300)
        offset = parse_int(params["offset"], 0)
        language = params["language"]
        _translator = params["translator"]

        opts = [limit: limit, offset: offset]
        opts = if language, do: Keyword.put(opts, :language, language), else: opts

        ayahs = Quran.list_ayahs_by_surah(surah.id, opts)

        render(conn, "ayahs.json", %{surah: surah, ayahs: ayahs})
    end
  end

  defp parse_int(nil, default), do: default

  defp parse_int(value, default) do
    case Integer.parse(value) do
      {int, ""} -> int
      _ -> default
    end
  end

  defp parse_atom(nil, default), do: default

  defp parse_atom(value, _default) when is_binary(value) do
    String.to_existing_atom(value)
  rescue
    ArgumentError -> :chapter_number
  end
end
