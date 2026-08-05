defmodule QuranApi.Admin.AuditLog do
  @moduledoc """
  Schema for audit logging all administrative actions.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias QuranApi.Auth.User

  @type t :: %__MODULE__{
          id: integer(),
          user_id: integer() | nil,
          action: String.t(),
          entity_type: String.t(),
          entity_id: integer() | nil,
          changes: map() | nil,
          ip_address: String.t() | nil,
          user_agent: String.t() | nil,
          inserted_at: DateTime.t()
        }

  schema "audit_logs" do
    belongs_to :user, User
    field :action, :string
    field :entity_type, :string
    field :entity_id, :integer
    field :changes, :map
    field :ip_address, :string
    field :user_agent, :string

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc """
  Changeset for creating an audit log entry.
  """
  @spec changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def changeset(audit_log, attrs) do
    audit_log
    |> cast(attrs, [
      :user_id,
      :action,
      :entity_type,
      :entity_id,
      :changes,
      :ip_address,
      :user_agent
    ])
    |> validate_required([:action, :entity_type])
  end
end
