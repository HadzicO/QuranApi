defmodule QuranApiWeb.TafsirController do
  @moduledoc """
  Controller for Tafsir endpoints.
  """
  use QuranApiWeb, :controller

  alias QuranApi.Quran

  action_fallback QuranApiWeb.FallbackController

  @doc """
  GET /api/v1/ayahs/:id/tafsir
  Gets tafsir for a specific ayah.
  """
  def show(conn, %{"id" => ayah_id} = params) do
    language = params["language"]
    author = params["author"]

    opts = []
    opts = if language, do: Keyword.put(opts, :language_code, language), else: opts
    opts = if author, do: Keyword.put(opts, :author, author), else: opts

    tafsirs = Quran.get_ayah_tafsirs(ayah_id, opts)
    render(conn, :show, tafsirs: tafsirs)
  end

  @doc """
  GET /api/v1/tafsir/authors
  Lists all available tafsir authors.
  """
  def authors(conn, _params) do
    authors = Quran.list_tafsir_authors()
    render(conn, :authors, authors: authors)
  end
end
