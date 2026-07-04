defmodule QuranApiWeb.AudioController do
  @moduledoc """
  Controller for Audio endpoints.
  """
  use QuranApiWeb, :controller

  alias QuranApi.Quran

  action_fallback QuranApiWeb.FallbackController

  @doc """
  GET /api/v1/reciters
  Lists all available reciters.
  """
  def reciters(conn, _params) do
    reciters = Quran.list_reciters()
    render(conn, :reciters, reciters: reciters)
  end

  @doc """
  GET /api/v1/audio/:ayah_id
  Gets audio for a specific ayah.
  """
  def show(conn, %{"id" => ayah_id} = params) do
    reciter = params["reciter"]
    opts = if reciter, do: [reciter: reciter], else: []

    audio = Quran.get_ayah_audio(ayah_id, opts)
    render(conn, :show, audio: audio)
  end

  @doc """
  GET /api/v1/surahs/:id/audio
  Gets audio for all ayahs in a surah.
  """
  def surah_audio(conn, %{"id" => surah_id} = params) do
    reciter = params["reciter"]
    opts = if reciter, do: [reciter: reciter], else: []

    audio = Quran.get_surah_audio(surah_id, opts)
    render(conn, :surah_audio, audio: audio)
  end
end
