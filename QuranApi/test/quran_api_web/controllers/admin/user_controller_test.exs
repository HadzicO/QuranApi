defmodule QuranApiWeb.Admin.UserControllerTest do
  use QuranApiWeb.ConnCase, async: true

  import QuranApi.AuthFixtures

  alias QuranApi.Auth
  alias QuranApi.Auth.Guardian

  @users_path "/admin/users"

  setup %{conn: conn} do
    admin = admin_fixture()
    token = valid_user_token(admin)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{token}")

    {:ok, conn: conn, admin: admin}
  end

  describe "GET /admin/users" do
    test "lists all users", %{conn: conn} do
      user_fixture()
      user_fixture()

      conn = get(conn, @users_path)

      assert %{"data" => users} = json_response(conn, 200)
      assert is_list(users)
      assert length(users) >= 2
    end

    test "filters users by role", %{conn: conn} do
      admin_fixture()
      user_fixture(%{role: "editor"})

      conn = get(conn, @users_path, %{"role" => "admin"})

      assert %{"data" => users} = json_response(conn, 200)
      assert Enum.all?(users, fn u -> u["role"] == "admin" end)
    end

    test "filters users by status", %{conn: conn} do
      user = user_fixture()
      Auth.change_status(user, "inactive")

      conn = get(conn, @users_path, %{"status" => "inactive"})

      assert %{"data" => users} = json_response(conn, 200)
      assert Enum.all?(users, fn u -> u["status"] == "inactive" end)
    end

    test "returns error without authentication", %{conn: _conn} do
      conn = build_conn() |> put_req_header("accept", "application/json")
      conn = get(conn, @users_path)

      assert %{"error" => %{"message" => _}} = json_response(conn, 401)
    end
  end

  describe "GET /admin/users/:id" do
    test "returns user by id", %{conn: conn} do
      user = user_fixture(%{email: "getme@example.com", name: "Get Me"})

      conn = get(conn, "#{@users_path}/#{user.id}")

      assert %{"data" => user_data} = json_response(conn, 200)
      assert user_data["id"] == user.id
      assert user_data["email"] == "getme@example.com"
      assert user_data["name"] == "Get Me"
    end

    test "returns 404 for non-existent user", %{conn: conn} do
      conn = get(conn, "#{@users_path}/999999")

      assert %{"errors" => %{"detail" => "Not Found"}} = json_response(conn, 404)
    end
  end

  describe "POST /admin/users" do
    test "creates user with valid data", %{conn: conn} do
      attrs = %{
        "email" => "newuser@example.com",
        "password" => "SecurePassword123",
        "name" => "New User",
        "role" => "editor"
      }

      conn = post(conn, @users_path, attrs)

      assert %{"data" => user_data} = json_response(conn, 201)
      assert user_data["email"] == "newuser@example.com"
      assert user_data["name"] == "New User"
      assert user_data["role"] == "editor"
    end

    test "returns error with invalid data", %{conn: conn} do
      attrs = %{
        "email" => "invalid-email",
        "password" => "short"
      }

      conn = post(conn, @users_path, attrs)

      assert %{"error" => _} = json_response(conn, 422)
    end

    test "returns error with duplicate email", %{conn: conn} do
      user_fixture(%{email: "duplicate@example.com"})

      attrs = %{
        "email" => "duplicate@example.com",
        "password" => "SecurePassword123",
        "name" => "Duplicate",
        "role" => "editor"
      }

      conn = post(conn, @users_path, attrs)

      assert %{"error" => _} = json_response(conn, 422)
    end
  end

  describe "PUT /admin/users/:id" do
    test "updates user with valid data", %{conn: conn} do
      user = user_fixture(%{email: "update@example.com", name: "Old Name"})

      attrs = %{
        "name" => "New Name",
        "email" => "newemail@example.com"
      }

      conn = put(conn, "#{@users_path}/#{user.id}", attrs)

      assert %{"data" => user_data} = json_response(conn, 200)
      assert user_data["name"] == "New Name"
      assert user_data["email"] == "newemail@example.com"
    end

    test "returns error with invalid data", %{conn: conn} do
      user = user_fixture()

      attrs = %{
        "email" => "invalid-email"
      }

      conn = put(conn, "#{@users_path}/#{user.id}", attrs)

      assert %{"error" => _} = json_response(conn, 422)
    end

    test "returns 404 for non-existent user", %{conn: conn} do
      attrs = %{"name" => "New Name"}

      conn = put(conn, "#{@users_path}/999999", attrs)

      assert %{"errors" => %{"detail" => "Not Found"}} = json_response(conn, 404)
    end
  end

  describe "DELETE /admin/users/:id" do
    test "deletes user", %{conn: conn} do
      user = user_fixture()

      conn = delete(conn, "#{@users_path}/#{user.id}")

      assert %{"message" => "User deleted successfully"} = json_response(conn, 200)

      # Verify user is deleted
      assert nil == Auth.get_user(user.id)
    end

    test "returns 404 for non-existent user", %{conn: conn} do
      conn = delete(conn, "#{@users_path}/999999")

      assert %{"errors" => %{"detail" => "Not Found"}} = json_response(conn, 404)
    end
  end

  describe "PATCH /admin/users/:id/role" do
    test "changes user role", %{conn: conn} do
      user = user_fixture(%{role: "editor"})

      conn = patch(conn, "#{@users_path}/#{user.id}/role", %{"role" => "admin"})

      assert %{"data" => user_data} = json_response(conn, 200)
      assert user_data["role"] == "admin"
    end

    test "returns error with invalid role", %{conn: conn} do
      user = user_fixture()

      conn = patch(conn, "#{@users_path}/#{user.id}/role", %{"role" => "invalid"})

      assert %{"error" => _} = json_response(conn, 422)
    end

    test "returns 404 for non-existent user", %{conn: conn} do
      conn = patch(conn, "#{@users_path}/999999/role", %{"role" => "admin"})

      assert %{"errors" => %{"detail" => "Not Found"}} = json_response(conn, 404)
    end
  end

  describe "PATCH /admin/users/:id/status" do
    test "changes user status", %{conn: conn} do
      user = user_fixture(%{status: "active"})

      conn = patch(conn, "#{@users_path}/#{user.id}/status", %{"status" => "suspended"})

      assert %{"data" => user_data} = json_response(conn, 200)
      assert user_data["status"] == "suspended"
    end

    test "returns error with invalid status", %{conn: conn} do
      user = user_fixture()

      conn = patch(conn, "#{@users_path}/#{user.id}/status", %{"status" => "invalid"})

      assert %{"error" => _} = json_response(conn, 422)
    end

    test "returns 404 for non-existent user", %{conn: conn} do
      conn = patch(conn, "#{@users_path}/999999/status", %{"status" => "inactive"})

      assert %{"errors" => %{"detail" => "Not Found"}} = json_response(conn, 404)
    end
  end

  describe "POST /admin/users/:id/reset_password" do
    test "resets user password", %{conn: conn} do
      user = user_fixture()

      conn = post(conn, "#{@users_path}/#{user.id}/reset_password")

      assert %{"message" => message, "new_password" => new_password} = json_response(conn, 200)
      assert message =~ "Password reset successfully"
      assert is_binary(new_password)
      assert String.length(new_password) >= 12
    end

    test "returns 404 for non-existent user", %{conn: conn} do
      conn = post(conn, "#{@users_path}/999999/reset_password")

      assert %{"errors" => %{"detail" => "Not Found"}} = json_response(conn, 404)
    end
  end

  describe "authorization" do
    test "editor cannot create users", %{conn: _conn} do
      editor = user_fixture(%{role: "editor"})
      token = valid_user_token(editor)

      conn =
        build_conn()
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(@users_path, %{
          "email" => "test@example.com",
          "password" => "SecurePassword123",
          "name" => "Test",
          "role" => "editor"
        })

      assert %{"error" => %{"message" => _}} = json_response(conn, 403)
    end

    test "readonly cannot create users", %{conn: _conn} do
      readonly = readonly_fixture()
      token = valid_user_token(readonly)

      conn =
        build_conn()
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(@users_path, %{
          "email" => "test@example.com",
          "password" => "SecurePassword123",
          "name" => "Test",
          "role" => "editor"
        })

      assert %{"error" => %{"message" => _}} = json_response(conn, 403)
    end
  end
end
