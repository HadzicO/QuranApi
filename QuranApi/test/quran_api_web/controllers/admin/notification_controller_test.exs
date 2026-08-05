defmodule QuranApiWeb.Admin.NotificationControllerTest do
  use QuranApiWeb.ConnCase, async: true

  import QuranApi.AuthFixtures
  import QuranApi.AdminFixtures

  @notifications_path "/admin/notifications"

  setup %{conn: conn} do
    user = user_fixture()
    token = valid_user_token(user)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{token}")

    {:ok, conn: conn, user: user}
  end

  describe "GET /admin/notifications" do
    test "lists user's notifications", %{conn: conn, user: user} do
      notification_fixture(%{user: user, title: "Test 1"})
      notification_fixture(%{user: user, title: "Test 2"})

      # Create notification for another user (should not appear)
      other_user = user_fixture()
      notification_fixture(%{user: other_user, title: "Other User"})

      conn = get(conn, @notifications_path)

      assert %{"data" => notifications} = json_response(conn, 200)
      assert is_list(notifications)
      assert length(notifications) >= 2

      # Verify all notifications belong to this user
      assert Enum.all?(notifications, fn n -> n["user_id"] == user.id end)
    end

    test "filters unread notifications", %{conn: conn, user: user} do
      notification_fixture(%{user: user, read: false, title: "Unread 1"})
      notification_fixture(%{user: user, read: false, title: "Unread 2"})
      notification_fixture(%{user: user, read: true, title: "Read"})

      conn = get(conn, @notifications_path, %{"unread_only" => "true"})

      assert %{"data" => notifications} = json_response(conn, 200)
      assert Enum.all?(notifications, fn n -> n["read"] == false end)
    end

    test "supports pagination", %{conn: conn, user: user} do
      # Create multiple notifications
      for i <- 1..25 do
        notification_fixture(%{user: user, title: "Notification #{i}"})
      end

      # Get first page
      conn = get(conn, @notifications_path, %{"page" => "1", "per_page" => "10"})

      assert %{"data" => notifications, "pagination" => pagination} = json_response(conn, 200)
      assert length(notifications) <= 10
      assert pagination["page"] == 1
      assert pagination["per_page"] == 10
    end

    test "requires authentication", %{conn: _conn} do
      conn = build_conn() |> put_req_header("accept", "application/json")
      conn = get(conn, @notifications_path)

      assert %{"error" => %{"message" => _}} = json_response(conn, 401)
    end
  end

  describe "POST /admin/notifications/:id/mark_read" do
    test "marks notification as read", %{conn: conn, user: user} do
      notification = notification_fixture(%{user: user, read: false})

      conn = post(conn, "#{@notifications_path}/#{notification.id}/mark_read")

      assert %{"data" => notification_data} = json_response(conn, 200)
      assert notification_data["read"] == true
      assert notification_data["id"] == notification.id
    end

    test "returns 404 for non-existent notification", %{conn: conn} do
      conn = post(conn, "#{@notifications_path}/999999/mark_read")

      assert %{"errors" => %{"detail" => "Not Found"}} = json_response(conn, 404)
    end

    test "returns 403 when accessing another user's notification", %{conn: _conn} do
      other_user = user_fixture()
      notification = notification_fixture(%{user: other_user, read: false})

      # Use first user's connection
      user = user_fixture()
      token = valid_user_token(user)

      conn =
        build_conn()
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer #{token}")
        |> post("#{@notifications_path}/#{notification.id}/mark_read")

      assert %{"error" => %{"message" => _}} = json_response(conn, 403)
    end

    test "idempotent - marking already read notification", %{conn: conn, user: user} do
      notification = notification_fixture(%{user: user, read: true})

      conn = post(conn, "#{@notifications_path}/#{notification.id}/mark_read")

      assert %{"data" => notification_data} = json_response(conn, 200)
      assert notification_data["read"] == true
    end
  end

  describe "POST /admin/notifications/mark_all_read" do
    test "marks all user notifications as read", %{conn: conn, user: user} do
      notification_fixture(%{user: user, read: false})
      notification_fixture(%{user: user, read: false})
      notification_fixture(%{user: user, read: false})

      # Other user's notification should not be affected
      other_user = user_fixture()
      other_notification = notification_fixture(%{user: other_user, read: false})

      conn = post(conn, "#{@notifications_path}/mark_all_read")

      assert %{"message" => message} = json_response(conn, 200)
      assert message =~ "marked as read"

      # Verify all user's notifications are read
      notifications = QuranApi.Admin.list_user_notifications(user.id)
      assert Enum.all?(notifications, fn n -> n.read == true end)

      # Verify other user's notification is unchanged
      other_notif = QuranApi.Admin.get_notification(other_notification.id)
      assert other_notif.read == false
    end

    test "works when user has no notifications", %{conn: conn} do
      conn = post(conn, "#{@notifications_path}/mark_all_read")

      assert %{"message" => message} = json_response(conn, 200)
      assert message =~ "marked as read"
    end

    test "works when all notifications already read", %{conn: conn, user: user} do
      notification_fixture(%{user: user, read: true})
      notification_fixture(%{user: user, read: true})

      conn = post(conn, "#{@notifications_path}/mark_all_read")

      assert %{"message" => message} = json_response(conn, 200)
      assert message =~ "marked as read"
    end

    test "requires authentication", %{conn: _conn} do
      conn = build_conn() |> put_req_header("accept", "application/json")
      conn = post(conn, "#{@notifications_path}/mark_all_read")

      assert %{"error" => %{"message" => _}} = json_response(conn, 401)
    end
  end
end
