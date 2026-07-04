defmodule QuranApiWeb.TranslationJSON do
  @moduledoc """
  JSON rendering for Translation resources.
  """

  def index(%{translators: translators}) do
    %{data: translators}
  end

  def show(%{translations: translations}) do
    %{
      data: for(translation <- translations, do: full_data(translation))
    }
  end

  def translations(%{translations: translations}) do
    %{
      data: for(translation <- translations, do: data(translation))
    }
  end

  defp data(translation) do
    %{
      language_code: translation.language_code,
      translator: translation.translator,
      text: translation.text
    }
  end

  defp full_data(translation) do
    base = data(translation)

    case translation.ayah do
      %Ecto.Association.NotLoaded{} ->
        base

      ayah ->
        Map.put(base, :ayah, %{
          id: ayah.id,
          surah_id: ayah.surah_id,
          ayah_number: ayah.ayah_number,
          global_number: ayah.global_number,
          arabic_text: ayah.arabic_text
        })
    end
  end
end
