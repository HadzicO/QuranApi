defmodule QuranApiWeb.AyahJSON do
  @moduledoc """
  JSON rendering for Ayah resources.
  """

  alias QuranApi.Quran.{Ayah, Surah}

  @doc """
  Renders a list of ayahs.
  """
  def index(%{ayahs: ayahs}) do
    %{data: for(ayah <- ayahs, do: data(ayah))}
  end

  @doc """
  Renders a single ayah.
  """
  def show(%{ayah: ayah}) do
    %{data: data(ayah)}
  end

  defp data(%Ayah{} = ayah) do
    base = %{
      id: ayah.id,
      ayah_number: ayah.ayah_number,
      global_number: ayah.global_number,
      arabic_text: ayah.arabic_text
    }

    base
    |> maybe_add_surah(ayah)
    |> maybe_add_translations(ayah)
    |> maybe_add_tafsirs(ayah)
    |> maybe_add_topics(ayah)
  end

  defp maybe_add_surah(data, %{surah: %Ecto.Association.NotLoaded{}}), do: data

  defp maybe_add_surah(data, %{surah: %Surah{} = surah}) do
    Map.put(data, :surah, %{
      id: surah.id,
      chapter_number: surah.chapter_number,
      name_ar: surah.name_ar,
      name_en: surah.name_en,
      name_bs: surah.name_bs,
      revelation_type: surah.revelation_type
    })
  end

  defp maybe_add_translations(data, %{translations: %Ecto.Association.NotLoaded{}}), do: data

  defp maybe_add_translations(data, %{translations: translations}) when is_list(translations) do
    Map.put(
      data,
      :translations,
      Enum.map(translations, fn t ->
        %{
          language_code: t.language_code,
          translator: t.translator,
          text: t.text
        }
      end)
    )
  end

  defp maybe_add_tafsirs(data, %{tafsirs: %Ecto.Association.NotLoaded{}}), do: data

  defp maybe_add_tafsirs(data, %{tafsirs: tafsirs}) when is_list(tafsirs) do
    Map.put(
      data,
      :tafsirs,
      Enum.map(tafsirs, fn t ->
        %{
          author: t.author,
          language_code: t.language_code,
          text: t.text
        }
      end)
    )
  end

  defp maybe_add_topics(data, %{topics: %Ecto.Association.NotLoaded{}}), do: data

  defp maybe_add_topics(data, %{topics: topics}) when is_list(topics) do
    Map.put(
      data,
      :topics,
      Enum.map(topics, fn t ->
        %{
          slug: t.slug,
          name: t.name
        }
      end)
    )
  end
end
