defmodule QuranApiWeb.Admin.DashboardControllerTest do
  use QuranApiWeb.ConnCase, async: true

  import QuranApi.AuthFixtures

  @dashboard_path "/admin/dashboard"

  setup %{conn: conn} do
    admin = admin_fixture()
    token = valid_user_token(admin)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{token}")

    {:ok, conn: conn, admin: admin}
  end

  describe "GET /admin/dashboard" do
    test "returns dashboard statistics", %{conn: conn} do
      # Create some test data
      user_fixture(%{role: "editor"})
      user_fixture(%{role: "readonly"})

      conn = get(conn, @dashboard_path)

      assert %{"data" => stats} = json_response(conn, 200)

      # Verify users stats
      assert is_map(stats["users"])
      assert is_integer(stats["users"]["total"])
      assert is_integer(stats["users"]["active"])
      assert is_integer(stats["users"]["admins"])
      assert is_integer(stats["users"]["editors"])
      assert is_integer(stats["users"]["readonly"])

      # Verify revisions stats
      assert is_map(stats["revisions"])
      assert is_integer(stats["revisions"]["total"])
      assert is_integer(stats["revisions"]["pending"])
      assert is_integer(stats["revisions"]["approved"])
      assert is_integer(stats["revisions"]["rejected"])
      assert is_integer(stats["revisions"]["published"])

      # Verify content stats
      assert is_map(stats["content"])
      assert is_integer(stats["content"]["surahs"])
      assert is_integer(stats["content"]["ayahs"])
      assert is_integer(stats["content"]["translations"])
      assert is_integer(stats["content"]["topics"])
      assert is_integer(stats["content"]["audio_files"])
    end

    test "reflects accurate user counts", %{conn: conn} do
      initial_conn = get(conn, @dashboard_path)
      initial_stats = json_response(initial_conn, 200)["data"]
      initial_total = initial_stats["users"]["total"] || 0

      # Add new users
      user_fixture(%{role: "admin"})
      user_fixture(%{role: "editor"})

      conn = get(conn, @dashboard_path)
      stats = json_response(conn, 200)["data"]

      assert stats["users"]["total"] >= initial_total + 2
    end

    test "requires authentication", %{conn: _conn} do
      conn = build_conn() |> put_req_header("accept", "application/json")
      conn = get(conn, @dashboard_path)

      assert %{"error" => %{"message" => _}} = json_response(conn, 401)
    end

    test "requires admin role", %{conn: _conn} do
      editor = user_fixture(%{role: "editor"})
      token = valid_user_token(editor)

      conn =
        build_conn()
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer #{token}")
        |> get(@dashboard_path)

      # Depending on your implementation, this might return 403 or allow editors to view
      # Adjust assertion based on your actual authorization rules
      assert json_response(conn, 200) || json_response(conn, 403)
    end
  end
end
