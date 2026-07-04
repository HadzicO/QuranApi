defmodule QuranApiWeb.SurahJSON do
  @moduledoc """
  JSON rendering for Surah resources.
  """

  alias QuranApi.Quran.Surah

  @doc """
  Renders a list of surahs.
  """
  def index(%{surahs: surahs}) do
    %{data: for(surah <- surahs, do: data(surah))}
  end

  @doc """
  Renders a single surah.
  """
  def show(%{surah: surah}) do
    %{data: data(surah)}
  end

  @doc """
  Renders ayahs for a surah.
  """
  def ayahs(%{surah: surah, ayahs: ayahs}) do
    %{
      data: %{
        surah: data(surah),
        ayahs: for(ayah <- ayahs, do: ayah_data(ayah))
      }
    }
  end

  defp data(%Surah{} = surah) do
    %{
      id: surah.id,
      chapter_number: surah.chapter_number,
      name_ar: surah.name_ar,
      name_en: surah.name_en,
      name_bs: surah.name_bs,
      revelation_type: surah.revelation_type,
      verses_count: surah.verses_count
    }
  end

  defp ayah_data(ayah) do
    base = %{
      id: ayah.id,
      ayah_number: ayah.ayah_number,
      global_number: ayah.global_number,
      arabic_text: ayah.arabic_text
    }

    case ayah.translations do
      %Ecto.Association.NotLoaded{} ->
        base

      translations ->
        Map.put(base, :translations, Enum.map(translations, &translation_data/1))
    end
  end

  defp translation_data(translation) do
    %{
      language_code: translation.language_code,
      translator: translation.translator,
      text: translation.text
    }
  end
end
