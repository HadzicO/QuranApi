defmodule QuranApiWeb.SearchJSON do
  @moduledoc """
  JSON rendering for search results.
  """

  def index(%{result: result}) do
    %{
      data: result.results,
      meta: %{
        total: result.total,
        page: result.page,
        per_page: result.per_page,
        total_pages: result.total_pages
      }
    }
  end
end
