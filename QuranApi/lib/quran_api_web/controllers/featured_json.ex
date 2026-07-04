defmodule QuranApiWeb.FeaturedJSON do
  @moduledoc """
  JSON rendering for featured verses.
  """

  # Reuse AyahJSON rendering
  defdelegate index(assigns), to: QuranApiWeb.AyahJSON
end
