defmodule QuranApiWeb.TopicJSON do
  @moduledoc """
  JSON rendering for Topic resources.
  """

  alias QuranApi.Quran.Topic

  def index(%{topics: topics}) do
    %{data: for(topic <- topics, do: data(topic))}
  end

  def show(%{topic: topic, ayahs: ayahs}) do
    %{
      data: %{
        topic: data(topic),
        ayahs: for(ayah <- ayahs, do: ayah_data(ayah))
      }
    }
  end

  defp data(%Topic{} = topic) do
    %{
      id: topic.id,
      slug: topic.slug,
      name: topic.name
    }
  end

  defp ayah_data(ayah) do
    base = %{
      id: ayah.id,
      ayah_number: ayah.ayah_number,
      global_number: ayah.global_number,
      arabic_text: ayah.arabic_text
    }

    base
    |> maybe_add_surah(ayah)
    |> maybe_add_translations(ayah)
  end

  defp maybe_add_surah(data, %{surah: %Ecto.Association.NotLoaded{}}), do: data

  defp maybe_add_surah(data, %{surah: surah}) do
    Map.put(data, :surah, %{
      id: surah.id,
      chapter_number: surah.chapter_number,
      name_ar: surah.name_ar,
      name_en: surah.name_en
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
end
