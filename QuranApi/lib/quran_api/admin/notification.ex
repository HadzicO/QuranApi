defmodule QuranApi.Admin.Notification do
  @moduledoc """
  Schema for user notifications.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias QuranApi.Auth.User

  @type t :: %__MODULE__{
          id: integer(),
          user_id: integer(),
          type: String.t(),
          title: String.t(),
          message: String.t(),
          related_entity_type: String.t() | nil,
          related_entity_id: integer() | nil,
          read: boolean(),
          read_at: DateTime.t() | nil,
          inserted_at: DateTime.t()
        }

  @types [
    "translation_submitted",
    "translation_approved",
    "translation_rejected",
    "tafsir_submitted",
    "tafsir_approved",
    "tafsir_rejected",
    "editor_created",
    "comment_added"
  ]

  schema "notifications" do
    belongs_to :user, User
    field :type, :string
    field :title, :string
    field :message, :string
    field :related_entity_type, :string
    field :related_entity_id, :integer
    field :read, :boolean, default: false
    field :read_at, :utc_datetime

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc """
  Changeset for creating a notification.
  """
  @spec changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [
      :user_id,
      :type,
      :title,
      :message,
      :related_entity_type,
      :related_entity_id
    ])
    |> validate_required([:user_id, :type, :title, :message])
    |> validate_inclusion(:type, @types)
  end

  @doc """
  Changeset for marking notification as read.
  """
  @spec read_changeset(Ecto.Schema.t()) :: Ecto.Changeset.t()
  def read_changeset(notification) do
    change(notification, %{
      read: true,
      read_at: DateTime.utc_now() |> DateTime.truncate(:second)
    })
  end
end
