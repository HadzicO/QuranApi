defmodule QuranApiWeb.TafsirJSON do
  @moduledoc """
  JSON rendering for Tafsir resources.
  """

  def show(%{tafsirs: tafsirs}) do
    %{
      data: for(tafsir <- tafsirs, do: data(tafsir))
    }
  end

  def authors(%{authors: authors}) do
    %{data: authors}
  end

  defp data(tafsir) do
    %{
      author: tafsir.author,
      language_code: tafsir.language_code,
      text: tafsir.text
    }
  end
end
