defmodule QuranApiWeb.Admin.NotificationController do
  use QuranApiWeb, :controller

  alias QuranApi.Admin

  action_fallback QuranApiWeb.FallbackController

  @doc """
  List user notifications - GET /admin/notifications
  """
  def index(conn, params) do
    current_user = Guardian.Plug.current_resource(conn)
    page = Map.get(params, "page", "1") |> String.to_integer()
    per_page = Map.get(params, "per_page", "20") |> String.to_integer()
    read = Map.get(params, "read")

    read_filter =
      case read do
        "true" -> true
        "false" -> false
        _ -> nil
      end

    notifications =
      Admin.list_user_notifications(current_user.id,
        page: page,
        per_page: per_page,
        read: read_filter
      )

    # Get total count for pagination
    total_entries = Admin.count_user_notifications(current_user.id, read: read_filter)
    total_pages = ceil(total_entries / per_page)

    pagination = %{
      page: page,
      per_page: per_page,
      total_pages: total_pages,
      total_entries: total_entries
    }

    conn
    |> render(:index, notifications: notifications, pagination: pagination)
  end

  @doc """
  Mark notification as read - PATCH /admin/notifications/:id/read
  """
  def mark_read(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)

    with notification when not is_nil(notification) <- Admin.get_notification(id),
         true <- notification.user_id == current_user.id,
         {:ok, updated_notification} <- Admin.mark_notification_read(notification) do
      conn
      |> render(:show, notification: updated_notification)
    else
      nil -> {:error, :not_found}
      false -> {:error, :forbidden}
      error -> error
    end
  end

  @doc """
  Mark all notifications as read - POST /admin/notifications/read-all
  """
  def mark_all_read(conn, _params) do
    current_user = Guardian.Plug.current_resource(conn)
    {count, _} = Admin.mark_all_notifications_read(current_user.id)

    conn
    |> json(%{message: "#{count} notifications marked as read"})
  end
end
