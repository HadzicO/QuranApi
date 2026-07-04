defmodule QuranApiWeb.AyahController do
  @moduledoc """
  Controller for Ayah endpoints.
  """
  use QuranApiWeb, :controller

  alias QuranApi.Quran
  import Ecto.Query

  action_fallback QuranApiWeb.FallbackController

  @doc """
  GET /api/v1/ayahs/:id
  Gets a single ayah by ID.
  """
  def show(conn, %{"id" => id} = params) do
    language = params["language"]
    translator = params["translator"]

    preload = build_preload(language, translator)

    case Quran.get_ayah(id, preload: preload) do
      nil -> {:error, :not_found}
      ayah -> render(conn, :show, ayah: ayah)
    end
  end

  @doc """
  GET /api/v1/surahs/:surah_id/ayahs/:ayah_number
  Gets a specific ayah by surah ID and ayah number.
  """
  def show_by_surah(conn, %{"surah_id" => surah_id, "ayah_number" => ayah_number} = params) do
    language = params["language"]
    translator = params["translator"]

    preload = build_preload(language, translator)

    case Quran.get_ayah_by_surah_and_number(surah_id, ayah_number, preload: preload) do
      nil -> {:error, :not_found}
      ayah -> render(conn, :show, ayah: ayah)
    end
  end

  @doc """
  POST /api/v1/ayahs/batch
  Gets multiple ayahs by their references.
  Request body: ["2:255", "36:58", "112:1"]
  """
  def batch(conn, params) when is_list(params) do
    language = conn.query_params["language"]
    translator = conn.query_params["translator"]

    preload = build_preload(language, translator)

    case Quran.get_ayahs_by_references(params, preload: preload) do
      {:ok, ayahs} -> render(conn, :index, ayahs: ayahs)
      {:error, errors} -> {:error, errors}
    end
  end

  def batch(_conn, _params) do
    {:error, "Expected an array of ayah references"}
  end

  defp build_preload(nil, nil), do: [:surah]

  defp build_preload(language, nil) do
    [
      :surah,
      translations: from(t in QuranApi.Quran.Translation, where: t.language_code == ^language)
    ]
  end

  defp build_preload(language, translator) do
    [
      :surah,
      translations:
        from(t in QuranApi.Quran.Translation,
          where: t.language_code == ^language and t.translator == ^translator
        )
    ]
  end
end
