defmodule QuranApiWeb.Admin.RevisionControllerTest do
  use QuranApiWeb.ConnCase, async: true

  import QuranApi.AuthFixtures
  import QuranApi.AdminFixtures

  @revisions_path "/admin/revisions"

  setup %{conn: conn} do
    admin = admin_fixture()
    editor = user_fixture(%{role: "editor"})
    admin_token = valid_user_token(admin)
    editor_token = valid_user_token(editor)

    admin_conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{admin_token}")

    editor_conn =
      build_conn()
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{editor_token}")

    {:ok, admin_conn: admin_conn, editor_conn: editor_conn, admin: admin, editor: editor}
  end

  describe "GET /admin/revisions" do
    test "lists all revisions", %{admin_conn: conn} do
      revision_fixture()
      revision_fixture()

      conn = get(conn, @revisions_path)

      assert %{"data" => revisions} = json_response(conn, 200)
      assert is_list(revisions)
      assert length(revisions) >= 2
    end

    test "filters revisions by status", %{admin_conn: conn} do
      revision_fixture(%{status: "draft"})
      revision_fixture(%{status: "pending_review"})

      conn = get(conn, @revisions_path, %{"status" => "draft"})

      assert %{"data" => revisions} = json_response(conn, 200)
      assert Enum.all?(revisions, fn r -> r["status"] == "draft" end)
    end

    test "filters revisions by entity_type", %{admin_conn: conn} do
      revision_fixture(%{entity_type: "translation"})
      revision_fixture(%{entity_type: "tafsir"})

      conn = get(conn, @revisions_path, %{"entity_type" => "translation"})

      assert %{"data" => revisions} = json_response(conn, 200)
      assert Enum.all?(revisions, fn r -> r["entity_type"] == "translation" end)
    end

    test "requires authentication", %{admin_conn: _conn} do
      conn = build_conn() |> put_req_header("accept", "application/json")
      conn = get(conn, @revisions_path)

      assert %{"error" => %{"message" => "unauthenticated"}} = json_response(conn, 401)
    end
  end

  describe "POST /admin/revisions" do
    test "creates revision with valid data", %{editor_conn: conn, editor: editor} do
      attrs = %{
        "revision" => %{
          "entity_type" => "translation",
          "entity_id" => 123,
          "field_name" => "text",
          "old_value" => %{"text" => "Old text"},
          "new_value" => %{"text" => "New text"},
          "changes" => %{"text" => "New text"},
          "reason" => "Improved translation"
        }
      }

      conn = post(conn, @revisions_path, attrs)

      assert %{"data" => revision} = json_response(conn, 201)
      assert revision["entity_type"] == "translation"
      assert revision["entity_id"] == 123
      assert revision["status"] == "draft"
      assert revision["submitted_by_id"] == editor.id
    end

    test "returns error with invalid data", %{editor_conn: conn} do
      attrs = %{
        "revision" => %{
          "entity_type" => "translation"
          # Missing required fields
        }
      }

      conn = post(conn, @revisions_path, attrs)

      assert json_response(conn, 422)
    end

    test "requires authentication", %{editor_conn: _conn} do
      conn = build_conn() |> put_req_header("accept", "application/json")
      conn = post(conn, @revisions_path, %{"revision" => %{}})

      assert %{"error" => %{"message" => "unauthenticated"}} = json_response(conn, 401)
    end
  end

  describe "POST /admin/revisions/:id/submit" do
    test "submits draft revision for review", %{editor_conn: conn, editor: editor} do
      revision = revision_fixture(%{user: editor, status: "draft"})

      conn = post(conn, "#{@revisions_path}/#{revision.id}/submit")

      assert %{"data" => revision_data} = json_response(conn, 200)
      assert revision_data["status"] == "pending_review"
    end

    test "returns error for non-draft revision", %{editor_conn: conn, editor: editor} do
      revision = revision_fixture(%{user: editor, status: "pending_review"})

      conn = post(conn, "#{@revisions_path}/#{revision.id}/submit")

      assert %{"error" => %{"message" => _}} = json_response(conn, 400)
    end

    test "returns 404 for non-existent revision", %{editor_conn: conn} do
      conn = post(conn, "#{@revisions_path}/999999/submit")

      assert %{"errors" => %{"detail" => "Not Found"}} = json_response(conn, 404)
    end
  end

  describe "POST /admin/revisions/:id/approve" do
    test "admin can approve pending revision", %{admin_conn: conn, admin: admin} do
      revision = revision_fixture(%{status: "pending_review"})

      conn = post(conn, "#{@revisions_path}/#{revision.id}/approve", %{"notes" => "Looks good"})

      assert %{"data" => revision_data} = json_response(conn, 200)
      assert revision_data["status"] == "approved"
      assert revision_data["reviewed_by_id"] == admin.id
      assert revision_data["review_notes"] == "Looks good"
      assert revision_data["reviewed_at"] != nil
    end

    test "returns error for non-pending revision", %{admin_conn: conn} do
      revision = revision_fixture(%{status: "draft"})

      conn = post(conn, "#{@revisions_path}/#{revision.id}/approve")

      assert %{"error" => %{"message" => _}} = json_response(conn, 400)
    end

    test "editor cannot approve revision", %{editor_conn: conn} do
      revision = revision_fixture(%{status: "pending_review"})

      conn = post(conn, "#{@revisions_path}/#{revision.id}/approve")

      assert %{"error" => %{"message" => "Insufficient permissions"}} = json_response(conn, 403)
    end

    test "returns 404 for non-existent revision", %{admin_conn: conn} do
      conn = post(conn, "#{@revisions_path}/999999/approve")

      assert %{"errors" => %{"detail" => "Not Found"}} = json_response(conn, 404)
    end
  end

  describe "POST /admin/revisions/:id/reject" do
    test "admin can reject pending revision", %{admin_conn: conn, admin: admin} do
      revision = revision_fixture(%{status: "pending_review"})

      conn =
        post(conn, "#{@revisions_path}/#{revision.id}/reject", %{"reason" => "Needs improvement"})

      assert %{"data" => revision_data} = json_response(conn, 200)
      assert revision_data["status"] == "rejected"
      assert revision_data["reviewed_by_id"] == admin.id
      assert revision_data["review_notes"] == "Needs improvement"
      assert revision_data["reviewed_at"] != nil
    end

    test "returns error without reason", %{admin_conn: conn} do
      revision = revision_fixture(%{status: "pending_review"})

      conn = post(conn, "#{@revisions_path}/#{revision.id}/reject", %{})

      assert %{"error" => %{"message" => _}} = json_response(conn, 400)
    end

    test "returns error for non-pending revision", %{admin_conn: conn} do
      revision = revision_fixture(%{status: "draft"})

      conn = post(conn, "#{@revisions_path}/#{revision.id}/reject", %{"reason" => "No good"})

      assert %{"error" => %{"message" => _}} = json_response(conn, 400)
    end

    test "editor cannot reject revision", %{editor_conn: conn} do
      revision = revision_fixture(%{status: "pending_review"})

      conn = post(conn, "#{@revisions_path}/#{revision.id}/reject", %{"reason" => "Bad"})

      assert %{"error" => %{"message" => "Insufficient permissions"}} = json_response(conn, 403)
    end

    test "returns 404 for non-existent revision", %{admin_conn: conn} do
      conn = post(conn, "#{@revisions_path}/999999/reject", %{"reason" => "Missing"})

      assert %{"errors" => %{"detail" => "Not Found"}} = json_response(conn, 404)
    end
  end

  describe "POST /admin/revisions/:id/publish" do
    test "admin can publish approved revision", %{admin_conn: conn} do
      revision = revision_fixture(%{status: "approved"})

      conn = post(conn, "#{@revisions_path}/#{revision.id}/publish")

      assert %{"data" => revision_data} = json_response(conn, 200)
      assert revision_data["status"] == "published"
      assert revision_data["published_at"] != nil
    end

    test "returns error for non-approved revision", %{admin_conn: conn} do
      revision = revision_fixture(%{status: "pending_review"})

      conn = post(conn, "#{@revisions_path}/#{revision.id}/publish")

      assert %{"error" => %{"message" => _}} = json_response(conn, 400)
    end

    test "editor cannot publish revision", %{editor_conn: conn} do
      revision = revision_fixture(%{status: "approved"})

      conn = post(conn, "#{@revisions_path}/#{revision.id}/publish")

      assert %{"error" => %{"message" => "Insufficient permissions"}} = json_response(conn, 403)
    end

    test "returns 404 for non-existent revision", %{admin_conn: conn} do
      conn = post(conn, "#{@revisions_path}/999999/publish")

      assert %{"errors" => %{"detail" => "Not Found"}} = json_response(conn, 404)
    end
  end
end
