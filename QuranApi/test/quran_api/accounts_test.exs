defmodule QuranApi.AccountsTest do
  use QuranApi.DataCase

  alias QuranApi.Accounts

  describe "users" do
    alias QuranApi.Accounts.User

    import QuranApi.AccountsFixtures

    @invalid_attrs %{role: nil, email: nil, password_hash: nil, is_active: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      users = Accounts.list_users()
      assert Enum.any?(users, fn u -> u.id == user.id end)
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      fetched_user = Accounts.get_user!(user.id)
      assert fetched_user.id == user.id
      assert fetched_user.email == user.email
      assert fetched_user.role == user.role
      assert fetched_user.is_active == user.is_active
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{
        role: "admin",
        email: "example@example.com",
        password: "password123",
        is_active: true
      }

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.role == "admin"
      assert user.email == "example@example.com"
      assert is_binary(user.password_hash)
      assert user.is_active == true
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()

      update_attrs = %{
        role: "content_writer",
        email: "test@example.com",
        is_active: false
      }

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.role == "content_writer"
      assert user.email == "test@example.com"
      assert user.is_active == false
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user.id == Accounts.get_user!(user.id).id
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
