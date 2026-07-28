defmodule QuranApi.Admin.Revision do
  @moduledoc """
  Schema for tracking content revisions and approval workflow.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias QuranApi.Auth.User

  @type t :: %__MODULE__{
          id: integer(),
          user_id: integer() | nil,
          entity_type: String.t(),
          entity_id: integer(),
          status: String.t(),
          old_value: map() | nil,
          new_value: map(),
          reason: String.t() | nil,
          reviewed_by_id: integer() | nil,
          reviewed_at: DateTime.t() | nil,
          review_notes: String.t() | nil,
          published_at: DateTime.t() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @statuses [:draft, :pending_review, :approved, :rejected, :published]

  schema "revisions" do
    belongs_to :user, User
    field :entity_type, :string
    field :entity_id, :integer

    field :status, Ecto.Enum,
      values: [:draft, :pending_review, :approved, :rejected, :published],
      default: :draft

    field :old_value, :map
    field :new_value, :map
    field :reason, :string
    belongs_to :reviewed_by, User
    field :reviewed_at, :utc_datetime
    field :review_notes, :string
    field :published_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset for creating a revision.
  """
  @spec changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def changeset(revision, attrs) do
    revision
    |> cast(attrs, [
      :user_id,
      :entity_type,
      :entity_id,
      :status,
      :old_value,
      :new_value,
      :reason
    ])
    |> validate_required([:entity_type, :entity_id, :new_value])
    |> validate_inclusion(:status, @statuses)
  end

  @doc """
  Changeset for submitting a revision for review.
  """
  @spec submit_changeset(Ecto.Schema.t()) :: Ecto.Changeset.t()
  def submit_changeset(revision) do
    revision
    |> change(%{status: :pending_review})
    |> validate_status_transition(:draft, "Only draft revisions can be submitted")
  end

  @doc """
  Changeset for approving a revision.
  """
  @spec approve_changeset(Ecto.Schema.t(), integer(), String.t() | nil) :: Ecto.Changeset.t()
  def approve_changeset(revision, reviewer_id, notes \\ nil) do
    revision
    |> change(%{
      status: :approved,
      reviewed_by_id: reviewer_id,
      reviewed_at: DateTime.utc_now() |> DateTime.truncate(:second),
      review_notes: notes
    })
    |> validate_status_transition(:pending_review, "Only pending revisions can be approved")
  end

  @doc """
  Changeset for rejecting a revision.
  """
  @spec reject_changeset(Ecto.Schema.t(), integer(), String.t() | nil) :: Ecto.Changeset.t()
  def reject_changeset(revision, reviewer_id, notes \\ nil) do
    revision
    |> change(%{
      status: :rejected,
      reviewed_by_id: reviewer_id,
      reviewed_at: DateTime.utc_now() |> DateTime.truncate(:second),
      review_notes: notes
    })
    |> validate_status_transition(:pending_review, "Only pending revisions can be rejected")
    |> validate_required([:review_notes], message: "Reason is required for rejection")
  end

  @doc """
  Changeset for publishing a revision.
  """
  @spec publish_changeset(Ecto.Schema.t()) :: Ecto.Changeset.t()
  def publish_changeset(revision) do
    change(revision, %{
      status: :published,
      published_at: DateTime.utc_now() |> DateTime.truncate(:second)
    })
  end

  # Private helper to validate status transitions
  defp validate_status_transition(changeset, expected_status, error_message) do
    revision = changeset.data

    if revision.status == expected_status do
      changeset
    else
      add_error(changeset, :status, error_message)
    end
  end
end
