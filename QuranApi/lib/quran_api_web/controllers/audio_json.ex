defmodule QuranApiWeb.AudioJSON do
  @moduledoc """
  JSON rendering for Audio resources.
  """

  def reciters(%{reciters: reciters}) do
    %{data: reciters}
  end

  def show(%{audio: audio}) do
    %{
      data: for(a <- audio, do: data(a))
    }
  end

  def surah_audio(%{audio: audio}) do
    %{
      data: for(a <- audio, do: surah_audio_data(a))
    }
  end

  defp data(audio) do
    %{
      reciter: audio.reciter,
      audio_url: audio.audio_url,
      duration: audio.duration
    }
  end

  defp surah_audio_data(audio) do
    base = data(audio)

    case audio.ayah do
      %Ecto.Association.NotLoaded{} ->
        base

      ayah ->
        Map.put(base, :ayah_number, ayah.ayah_number)
    end
  end
end
