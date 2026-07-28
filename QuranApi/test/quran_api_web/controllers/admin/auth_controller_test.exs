defmodule QuranApiWeb.Admin.AuthControllerTest do
  use QuranApiWeb.ConnCase, async: true

  import QuranApi.AuthFixtures

  alias QuranApi.Auth
  alias QuranApi.Auth.Guardian

  @login_path "/admin/login"
  @logout_path "/admin/logout"
  @me_path "/admin/me"
  @refresh_path "/admin/refresh"

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "POST /admin/login" do
    test "authenticates user with valid credentials", %{conn: conn} do
      user_fixture(%{email: "login@example.com", password: "SecurePassword123"})

      conn =
        post(conn, @login_path, %{
          "email" => "login@example.com",
          "password" => "SecurePassword123"
        })

      assert %{
               "access_token" => access_token,
               "refresh_token" => refresh_token,
               "user" => user_data
             } = json_response(conn, 200)

      assert is_binary(access_token)
      assert is_binary(refresh_token)
      assert user_data["email"] == "login@example.com"
    end

    test "returns error with invalid credentials", %{conn: conn} do
      user_fixture(%{email: "login@example.com", password: "SecurePassword123"})

      conn =
        post(conn, @login_path, %{
          "email" => "login@example.com",
          "password" => "WrongPassword"
        })

      assert %{"error" => %{"message" => _}} = json_response(conn, 401)
    end

    test "returns error for non-existent user", %{conn: conn} do
      conn =
        post(conn, @login_path, %{
          "email" => "nonexistent@example.com",
          "password" => "SecurePassword123"
        })

      assert %{"error" => %{"message" => _}} = json_response(conn, 401)
    end

    test "returns error for inactive user", %{conn: conn} do
      user = user_fixture(%{email: "inactive@example.com", password: "SecurePassword123"})
      Auth.change_status(user, "inactive")

      conn =
        post(conn, @login_path, %{
          "email" => "inactive@example.com",
          "password" => "SecurePassword123"
        })

      assert %{"error" => %{"message" => message}} = json_response(conn, 403)
      assert message =~ "inactive"
    end

    test "returns error for suspended user", %{conn: conn} do
      user = user_fixture(%{email: "suspended@example.com", password: "SecurePassword123"})
      Auth.change_status(user, "suspended")

      conn =
        post(conn, @login_path, %{
          "email" => "suspended@example.com",
          "password" => "SecurePassword123"
        })

      assert %{"error" => %{"message" => message}} = json_response(conn, 403)
      assert message =~ "suspended"
    end

    test "returns error with missing email", %{conn: conn} do
      conn =
        post(conn, @login_path, %{
          "password" => "SecurePassword123"
        })

      assert %{"error" => %{"message" => _}} = json_response(conn, 400)
    end

    test "returns error with missing password", %{conn: conn} do
      conn =
        post(conn, @login_path, %{
          "email" => "test@example.com"
        })

      assert %{"error" => _} = json_response(conn, 400)
    end
  end

  describe "POST /admin/logout" do
    test "logs out authenticated user", %{conn: conn} do
      user = user_fixture()
      token = valid_user_token(user)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(@logout_path)

      assert %{"message" => message} = json_response(conn, 200)
      assert message =~ "Logged out"
    end

    test "returns error without authentication", %{conn: conn} do
      conn = post(conn, @logout_path)

      assert %{"error" => %{"message" => _}} = json_response(conn, 401)
    end

    test "returns error with invalid token", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer invalid.token.here")
        |> post(@logout_path)

      assert %{"error" => %{"message" => _}} = json_response(conn, 401)
    end
  end

  describe "GET /admin/me" do
    test "returns current user information", %{conn: conn} do
      user = user_fixture(%{email: "me@example.com", first_name: "Me", last_name: "User"})
      token = valid_user_token(user)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> get(@me_path)

      assert %{"data" => user_data} = json_response(conn, 200)
      assert user_data["email"] == "me@example.com"
      assert user_data["first_name"] == "Me"
      assert user_data["last_name"] == "User"
      assert user_data["id"] == user.id
    end

    test "returns error without authentication", %{conn: conn} do
      conn = get(conn, @me_path)

      assert %{"error" => %{"message" => _}} = json_response(conn, 401)
    end

    test "returns error with invalid token", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer invalid.token.here")
        |> get(@me_path)

      assert %{"error" => %{"message" => _}} = json_response(conn, 401)
    end
  end

  describe "POST /admin/refresh" do
    test "returns new access token with valid refresh token", %{conn: conn} do
      user = user_fixture()

      {:ok, refresh_token, _claims} =
        Guardian.encode_and_sign(user, %{}, token_type: "refresh")

      conn =
        post(conn, @refresh_path, %{
          "refresh_token" => refresh_token
        })

      assert %{
               "data" => %{
                 "access_token" => new_access_token,
                 "refresh_token" => new_refresh_token
               }
             } = json_response(conn, 200)

      assert is_binary(new_access_token)
      assert is_binary(new_refresh_token)
    end

    test "returns error with invalid refresh token", %{conn: conn} do
      conn =
        post(conn, @refresh_path, %{
          "refresh_token" => "invalid.token.here"
        })

      assert %{"error" => %{"message" => _}} = json_response(conn, 401)
    end

    test "returns error with missing refresh token", %{conn: conn} do
      conn = post(conn, @refresh_path, %{})

      assert %{"error" => %{"message" => _}} = json_response(conn, 400)
    end

    test "returns error with access token instead of refresh token", %{conn: conn} do
      user = user_fixture()
      {:ok, access_token, _claims} = Guardian.encode_and_sign(user)

      conn =
        post(conn, @refresh_path, %{
          "refresh_token" => access_token
        })

      # Should fail because it's not a refresh token
      assert %{"error" => %{"message" => _}} = json_response(conn, 401)
    end
  end
end
