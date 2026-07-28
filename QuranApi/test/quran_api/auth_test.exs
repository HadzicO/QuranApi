defmodule QuranApi.AuthTest do
  use QuranApi.DataCase, async: true

  alias QuranApi.Auth
  alias QuranApi.Auth.User

  import QuranApi.AuthFixtures

  alias QuranApi.Auth.Guardian

  describe "users" do
    @valid_user_attrs %{
      email: "test@example.com",
      password: "SecurePassword123",
      name: "Test User",
      role: "editor"
    }

    @update_attrs %{
      email: "updated@example.com",
      name: "Updated Name"
    }

    @invalid_attrs %{email: nil, password: nil, name: nil}

    test "list_users/1 returns all users" do
      user = user_fixture()
      users = Auth.list_users()
      assert length(users) >= 1
      assert Enum.any?(users, fn u -> u.id == user.id end)
    end

    test "get_user/1 returns the user with given id" do
      user = user_fixture()
      assert Auth.get_user(user.id).id == user.id
    end

    test "get_user_by_email/1 returns the user with given email" do
      user = user_fixture(%{email: "specific@example.com"})
      assert Auth.get_user_by_email("specific@example.com").id == user.id
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Auth.create_user(@valid_user_attrs)
      assert user.email == "test@example.com"
      assert user.name == "Test User"
      assert user.role == :editor
      assert user.status == :active
      assert Argon2.verify_pass("SecurePassword123", user.password_hash)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auth.create_user(@invalid_attrs)
    end

    test "create_user/1 with weak password returns error" do
      attrs = Map.put(@valid_user_attrs, :password, "weak")
      assert {:error, changeset} = Auth.create_user(attrs)
      assert "should be at least 8 character(s)" in errors_on(changeset).password
    end

    test "create_user/1 with duplicate email returns error" do
      user_fixture(%{email: "duplicate@example.com"})

      assert {:error, changeset} =
               Auth.create_user(Map.put(@valid_user_attrs, :email, "duplicate@example.com"))

      assert "has already been taken" in errors_on(changeset).email
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Auth.update_user(user, @update_attrs)
      assert user.email == "updated@example.com"
      assert user.name == "Updated Name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Auth.update_user(user, %{email: nil})
      assert user.id == Auth.get_user(user.id).id
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Auth.delete_user(user)
      assert nil == Auth.get_user(user.id)
    end

    test "change_role/2 changes user role" do
      user = user_fixture(%{role: "editor"})
      assert {:ok, %User{} = user} = Auth.change_role(user, "admin")
      assert user.role == :admin
    end

    test "change_status/2 changes user status" do
      user = user_fixture(%{status: "active"})
      assert {:ok, %User{} = user} = Auth.change_status(user, "suspended")
      assert user.status == :suspended
    end
  end

  describe "authentication" do
    test "authenticate/3 with valid credentials returns user and tokens" do
      user_fixture(%{email: "auth@example.com", password: "SecurePassword123"})

      assert {:ok, user, tokens} =
               Auth.authenticate("auth@example.com", "SecurePassword123", "127.0.0.1")

      assert user.email == "auth@example.com"
      assert is_binary(tokens.access_token)
      assert is_binary(tokens.refresh_token)
    end

    test "authenticate/3 with invalid password returns error" do
      user_fixture(%{email: "auth@example.com", password: "SecurePassword123"})

      assert {:error, :invalid_credentials} =
               Auth.authenticate("auth@example.com", "WrongPassword", "127.0.0.1")
    end

    test "authenticate/3 with inactive user returns error" do
      user = user_fixture(%{email: "inactive@example.com", password: "SecurePassword123"})
      Auth.change_status(user, "inactive")

      assert {:error, :inactive_user} =
               Auth.authenticate("inactive@example.com", "SecurePassword123", "127.0.0.1")
    end

    test "authenticate/3 with suspended user returns error" do
      user = user_fixture(%{email: "suspended@example.com", password: "SecurePassword123"})
      Auth.change_status(user, "suspended")

      assert {:error, :suspended} =
               Auth.authenticate("suspended@example.com", "SecurePassword123", "127.0.0.1")
    end

    test "verify_token/1 with valid token returns user" do
      user = user_fixture()
      token = valid_user_token(user)

      assert {:ok, verified_user, _claims} = Auth.verify_token(token)
      assert verified_user.id == user.id
    end

    test "verify_token/1 with invalid token returns error" do
      assert {:error, _reason} = Auth.verify_token("invalid.token.here")
    end

    test "refresh_access_token/1 with valid refresh token returns new access token" do
      user = user_fixture()

      {:ok, refresh_token, _claims} =
        Guardian.encode_and_sign(user, %{}, token_type: "refresh")

      assert {:ok, %{access_token: new_access_token, refresh_token: new_refresh_token}} =
               Auth.refresh_access_token(refresh_token)

      assert is_binary(new_access_token)
      assert is_binary(new_refresh_token)
    end
  end
end
