defmodule QuranApiWeb.MetadataJSON do
  @moduledoc """
  JSON rendering for metadata resources.
  """

  def languages(%{languages: languages}) do
    %{data: languages}
  end

  def stats(%{stats: stats}) do
    %{data: stats}
  end

  def metadata(%{metadata: metadata}) do
    %{data: metadata}
  end
end
