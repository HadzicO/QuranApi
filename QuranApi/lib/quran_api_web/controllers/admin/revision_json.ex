defmodule QuranApiWeb.Admin.RevisionJSON do
  @moduledoc """
  Renders revision responses.
  """

  def index(%{revisions: revisions}) do
    %{data: Enum.map(revisions, &revision_data/1)}
  end

  def show(%{revision: revision}) do
    %{data: revision_data(revision)}
  end

  defp revision_data(revision) do
    %{
      id: revision.id,
      entity_type: revision.entity_type,
      entity_id: revision.entity_id,
      status: revision.status,
      old_value: revision.old_value,
      new_value: revision.new_value,
      reason: revision.reason,
      submitted_by_id: revision.user_id,
      user: user_summary(revision.user),
      reviewed_by_id: revision.reviewed_by_id,
      reviewed_by: user_summary(revision.reviewed_by),
      reviewed_at: revision.reviewed_at,
      review_notes: revision.review_notes,
      published_at: revision.published_at,
      inserted_at: revision.inserted_at,
      updated_at: revision.updated_at
    }
  end

  defp user_summary(nil), do: nil

  defp user_summary(%Ecto.Association.NotLoaded{}), do: nil

  defp user_summary(user) do
    %{
      id: user.id,
      email: user.email,
      role: user.role
    }
  end
end
