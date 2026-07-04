defmodule QuranApiWeb.DailyJSON do
  @moduledoc """
  JSON rendering for daily ayah.
  """

  # Reuse AyahJSON rendering
  defdelegate show(assigns), to: QuranApiWeb.AyahJSON
end
