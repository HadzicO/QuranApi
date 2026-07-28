defmodule QuranApiWeb.Admin.NotificationJSON do
  @moduledoc """
  Renders notification responses.
  """

  def index(%{notifications: notifications, pagination: pagination}) do
    %{
      data: Enum.map(notifications, &notification_data/1),
      pagination: pagination
    }
  end

  def show(%{notification: notification}) do
    %{data: notification_data(notification)}
  end

  defp notification_data(notification) do
    %{
      id: notification.id,
      user_id: notification.user_id,
      type: notification.type,
      title: notification.title,
      message: notification.message,
      related_entity_type: notification.related_entity_type,
      related_entity_id: notification.related_entity_id,
      read: notification.read,
      read_at: notification.read_at,
      inserted_at: notification.inserted_at
    }
  end
end
