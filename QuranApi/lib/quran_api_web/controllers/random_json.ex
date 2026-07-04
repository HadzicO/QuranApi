defmodule QuranApiWeb.RandomJSON do
  @moduledoc """
  JSON rendering for random ayah.
  """

  # Reuse AyahJSON rendering
  defdelegate show(assigns), to: QuranApiWeb.AyahJSON
end
