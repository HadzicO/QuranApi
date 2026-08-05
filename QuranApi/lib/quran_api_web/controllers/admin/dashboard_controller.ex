defmodule QuranApiWeb.Admin.DashboardController do
  use QuranApiWeb, :controller

  alias QuranApi.Admin
  alias QuranApi.Quran

  action_fallback QuranApiWeb.FallbackController

  @doc """
  Get dashboard statistics - GET /admin/dashboard
  """
  def index(conn, _params) do
    admin_stats = Admin.get_dashboard_stats()

    # Get Quran-specific stats
    content_stats = %{
      content: %{
        surahs: Quran.count_surahs(),
        ayahs: Quran.count_ayahs(),
        translations: Quran.count_translations(),
        topics: Quran.count_topics(),
        audio_files: Quran.count_audio()
      }
    }

    stats = Map.merge(admin_stats, content_stats)

    conn
    |> json(%{data: stats})
  end
end
