defmodule QuranApi.AdminTest do
  use QuranApi.DataCase, async: true

  alias QuranApi.Admin
  alias QuranApi.Admin.{ApiKey, Notification, Revision}

  import QuranApi.AuthFixtures
  import QuranApi.AdminFixtures

  describe "revisions" do
    test "list_revisions/1 returns all revisions" do
      revision = revision_fixture()
      revisions = Admin.list_revisions()
      assert length(revisions) >= 1
      assert Enum.any?(revisions, fn r -> r.id == revision.id end)
    end

    test "list_revisions/1 filters by status" do
      revision_fixture(%{status: "draft"})
      revision_fixture(%{status: "pending_review"})

      drafts = Admin.list_revisions(status: "draft")
      assert Enum.all?(drafts, fn r -> r.status == :draft end)
    end

    test "get_revision/1 returns the revision with given id" do
      revision = revision_fixture()
      assert Admin.get_revision(revision.id).id == revision.id
    end

    test "create_revision/1 with valid data creates a revision" do
      user = user_fixture()

      attrs = %{
        entity_type: "translation",
        entity_id: 1,
        field_name: "text",
        old_value: %{"text" => "Old"},
        new_value: %{"text" => "New"},
        changes: %{"text" => "New"},
        reason: "Test",
        user_id: user.id
      }

      assert {:ok, %Revision{} = revision} = Admin.create_revision(attrs)
      assert revision.entity_type == "translation"
      assert revision.status == :draft
    end

    test "submit_revision/1 changes status to pending_review" do
      revision = revision_fixture()

      assert {:ok, %Revision{} = updated} = Admin.submit_revision(revision)
      assert updated.status == :pending_review
    end

    test "approve_revision/3 marks revision as approved" do
      admin = admin_fixture()
      revision = revision_fixture(%{status: "pending_review"})

      assert {:ok, %Revision{} = approved} =
               Admin.approve_revision(revision, admin.id, "Looks good")

      assert approved.status == :approved
      assert approved.reviewed_by_id == admin.id
      assert approved.review_notes == "Looks good"
      assert approved.reviewed_at != nil
    end

    test "reject_revision/3 marks revision as rejected" do
      admin = admin_fixture()
      revision = revision_fixture(%{status: "pending_review"})

      assert {:ok, %Revision{} = rejected} =
               Admin.reject_revision(revision, admin.id, "Needs work")

      assert rejected.status == :rejected
      assert rejected.reviewed_by_id == admin.id
      assert rejected.review_notes == "Needs work"
    end

    test "publish_revision/1 marks revision as published" do
      revision = revision_fixture(%{status: "approved"})

      assert {:ok, %Revision{} = published} = Admin.publish_revision(revision)
      assert published.status == :published
      assert published.published_at != nil
    end

    test "list_revisions/1 filters pending revisions" do
      revision_fixture(%{status: "draft"})
      _pending = revision_fixture(%{status: "pending_review"})
      revision_fixture(%{status: "approved"})

      result = Admin.list_revisions(status: "pending_review")
      assert length(result) >= 1
      assert Enum.all?(result, fn r -> r.status == :pending_review end)
    end
  end

  describe "notifications" do
    test "list_notifications/2 returns all notifications for user" do
      user = user_fixture()
      notification = notification_fixture(%{user: user})

      notifications = Admin.list_user_notifications(user.id)
      assert length(notifications) >= 1
      assert Enum.any?(notifications, fn n -> n.id == notification.id end)
    end

    test "list_notifications/2 filters unread notifications" do
      user = user_fixture()
      notification_fixture(%{user: user, read: false})
      notification_fixture(%{user: user, read: true})

      unread = Admin.list_user_notifications(user.id, unread_only: true)
      assert Enum.all?(unread, fn n -> n.read == false end)
    end

    test "get_notification/1 returns the notification with given id" do
      notification = notification_fixture()
      assert Admin.get_notification(notification.id).id == notification.id
    end

    test "create_notification/1 with valid data creates a notification" do
      user = user_fixture()

      attrs = %{
        user_id: user.id,
        type: "translation_submitted",
        title: "Test",
        message: "Test message",
        read: false
      }

      assert {:ok, %Notification{} = notification} = Admin.create_notification(attrs)
      assert notification.title == "Test"
      assert notification.read == false
    end

    test "mark_notification_read/1 marks notification as read" do
      notification = notification_fixture(%{read: false})

      assert {:ok, %Notification{} = updated} = Admin.mark_notification_read(notification)
      assert updated.read == true
    end

    test "mark_all_notifications_read/1 marks all user notifications as read" do
      user = user_fixture()
      notification_fixture(%{user: user, read: false})
      notification_fixture(%{user: user, read: false})

      assert {count, nil} = Admin.mark_all_notifications_read(user.id)
      assert count >= 2

      notifications = Admin.list_user_notifications(user.id)
      assert Enum.all?(notifications, fn n -> n.read == true end)
    end

    test "notify_user/5 creates notification for user" do
      user = user_fixture()

      assert {:ok, %Notification{}} =
               Admin.notify_user(user.id, "translation_submitted", "Title", "Message", %{})

      notifications = Admin.list_user_notifications(user.id)
      assert length(notifications) >= 1
    end

    test "notify_admins/4 creates notifications for all admin users" do
      admin1 = admin_fixture()
      admin2 = admin_fixture()
      _editor = user_fixture(%{role: "editor"})

      Admin.notify_admins("translation_submitted", "Admin Alert", "Important message", %{})

      admin1_notifications = Admin.list_user_notifications(admin1.id)
      admin2_notifications = Admin.list_user_notifications(admin2.id)

      assert length(admin1_notifications) >= 1
      assert length(admin2_notifications) >= 1
    end
  end

  describe "api_keys" do
    test "list_api_keys/1 returns all API keys for user" do
      user = user_fixture()
      api_key = api_key_fixture(%{user: user})

      api_keys = Admin.list_api_keys(user_id: user.id)
      assert length(api_keys) >= 1
      assert Enum.any?(api_keys, fn k -> k.id == api_key.id end)
    end

    test "get_api_key/1 returns the API key with given id" do
      api_key = api_key_fixture()
      assert Admin.get_api_key(api_key.id).id == api_key.id
    end

    test "create_api_key/1 with valid data creates an API key" do
      user = user_fixture()

      attrs = %{
        user_id: user.id,
        name: "Test Key",
        key_hash: :crypto.hash(:sha256, "test_key"),
        expires_at: DateTime.add(DateTime.utc_now(), 30, :day)
      }

      assert {:ok, %ApiKey{} = api_key, _plain_key} = Admin.create_api_key(attrs)
      assert api_key.name == "Test Key"
      assert api_key.status == "active"
    end

    test "revoke_api_key/1 marks API key as revoked" do
      api_key = api_key_fixture()

      assert {:ok, %ApiKey{} = revoked} = Admin.revoke_api_key(api_key)
      assert revoked.status == "revoked"
    end
  end

  describe "audit_logs" do
    test "create_audit_log/1 creates an audit log entry" do
      user = user_fixture()

      attrs = %{
        user_id: user.id,
        action: "create",
        entity_type: "user",
        entity_id: 123,
        changes: %{"name" => "Test"},
        ip_address: "127.0.0.1"
      }

      assert {:ok, audit_log} = Admin.create_audit_log(attrs)
      assert audit_log.action == "create"
      assert audit_log.entity_type == "user"
    end

    test "list_audit_logs/1 returns paginated audit logs" do
      user = user_fixture()
      Admin.log_action(user, "create", "user", 1, %{}, %{ip_address: "127.0.0.1"})

      logs = Admin.list_audit_logs()
      assert length(logs) >= 1
    end

    test "log_action/6 creates audit log and returns :ok" do
      user = user_fixture()

      assert {:ok, log} =
               Admin.log_action(
                 user,
                 "update",
                 "translation",
                 123,
                 %{"text" => "New"},
                 %{ip_address: "127.0.0.1"}
               )

      assert log.user_id == user.id
      assert log.action == "update"
      assert log.entity_type == "translation"
    end
  end

  describe "dashboard_stats" do
    test "get_dashboard_stats/0 returns comprehensive statistics" do
      user_fixture(%{role: "admin"})
      user_fixture(%{role: "editor"})
      revision_fixture(%{status: "pending_review"})

      stats = Admin.get_dashboard_stats()

      assert is_map(stats)
      assert is_map(stats.users)
      assert is_map(stats.revisions)

      assert is_integer(stats.users.total)
      assert is_integer(stats.users.admins)
      assert is_integer(stats.revisions.pending)
    end
  end
end
