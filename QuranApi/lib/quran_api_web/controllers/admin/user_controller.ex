defmodule QuranApiWeb.Admin.UserController do
  use QuranApiWeb, :controller

  alias QuranApi.Admin
  alias QuranApi.Auth

  action_fallback QuranApiWeb.FallbackController

  plug QuranApiWeb.Plugs.EnsureRole,
       "admin" when action in [:create, :delete, :change_role, :change_status]

  @doc """
  List all users - GET /admin/users
  """
  def index(conn, params) do
    page = Map.get(params, "page", "1") |> String.to_integer()
    per_page = Map.get(params, "per_page", "20") |> String.to_integer()
    role = Map.get(params, "role")
    status = Map.get(params, "status")

    users = Auth.list_users(page: page, per_page: per_page, role: role, status: status)

    conn
    |> render(:index, users: users)
  end

  @doc """
  Get single user - GET /admin/users/:id
  """
  def show(conn, %{"id" => id}) do
    case Auth.get_user(id) do
      nil -> {:error, :not_found}
      user -> render(conn, :show, user: user)
    end
  end

  @doc """
  Create user - POST /admin/users
  """
  def create(conn, %{"user" => user_params}) do
    current_user = Guardian.Plug.current_resource(conn)

    with {:ok, user} <- Auth.create_user(user_params) do
      # Log the action
      Admin.log_action(current_user, "create_user", "user", user.id, %{user: user_params}, %{})

      # Notify if editor was created
      if user.role == "editor" do
        Admin.notify_user(
          user.id,
          "editor_created",
          "Welcome to Quran API",
          "Your editor account has been created. You can now log in and start contributing.",
          %{}
        )
      end

      conn
      |> put_status(:created)
      |> render(:show, user: user)
    end
  end

  # Handle unwrapped params
  def create(conn, params) when is_map(params) do
    create(conn, %{"user" => params})
  end

  @doc """
  Update user - PUT /admin/users/:id
  """
  def update(conn, %{"id" => id, "user" => user_params}) do
    current_user = Guardian.Plug.current_resource(conn)

    with user when not is_nil(user) <- Auth.get_user(id),
         {:ok, updated_user} <- Auth.update_user(user, user_params) do
      # Log the action
      Admin.log_action(
        current_user,
        "update_user",
        "user",
        user.id,
        %{
          old: Map.take(user, [:email, :first_name, :last_name, :role, :status]),
          new: user_params
        },
        %{}
      )

      conn
      |> render(:show, user: updated_user)
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end

  # Handle unwrapped params for update
  def update(conn, %{"id" => id} = params) when is_map(params) do
    user_params = Map.delete(params, "id")
    update(conn, %{"id" => id, "user" => user_params})
  end

  @doc """
  Delete user - DELETE /admin/users/:id
  """
  def delete(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)

    with user when not is_nil(user) <- Auth.get_user(id),
         {:ok, _} <- Auth.delete_user(user) do
      # Log the action
      Admin.log_action(
        current_user,
        "delete_user",
        "user",
        user.id,
        %{deleted_user: user.email},
        %{}
      )

      conn
      |> put_status(:ok)
      |> json(%{message: "User deleted successfully"})
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end

  @doc """
  Change user role - PATCH /admin/users/:id/role
  """
  def change_role(conn, %{"id" => id, "role" => new_role}) do
    current_user = Guardian.Plug.current_resource(conn)

    with user when not is_nil(user) <- Auth.get_user(id),
         {:ok, updated_user} <- Auth.change_role(user, new_role) do
      # Log the action
      Admin.log_action(
        current_user,
        "change_role",
        "user",
        user.id,
        %{
          old_role: user.role,
          new_role: new_role
        },
        %{}
      )

      conn
      |> render(:show, user: updated_user)
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end

  @doc """
  Change user status - PATCH /admin/users/:id/status
  """
  def change_status(conn, %{"id" => id, "status" => new_status}) do
    current_user = Guardian.Plug.current_resource(conn)

    with user when not is_nil(user) <- Auth.get_user(id),
         {:ok, updated_user} <- Auth.change_status(user, new_status) do
      # Log the action
      Admin.log_action(
        current_user,
        "change_status",
        "user",
        user.id,
        %{
          old_status: user.status,
          new_status: new_status
        },
        %{}
      )

      conn
      |> render(:show, user: updated_user)
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end

  @doc """
  Reset user password - POST /admin/users/:id/reset_password
  Generates a random password and returns it
  """
  def reset_password(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)
    # Generate random password
    new_password = generate_random_password()

    with user when not is_nil(user) <- Auth.get_user(id),
         {:ok, _updated_user} <- Auth.update_password(user, %{password: new_password}) do
      # Log the action
      Admin.log_action(current_user, "reset_password", "user", user.id, %{}, %{})

      # Notify user
      Admin.notify_user(
        user.id,
        "password_reset",
        "Password Reset",
        "Your password has been reset by an administrator.",
        %{}
      )

      conn
      |> put_status(:ok)
      |> json(%{message: "Password reset successfully", new_password: new_password})
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end

  # Generate a random 12-character password
  defp generate_random_password do
    # Ensure password meets all requirements:
    # - At least 8 characters
    # - At least one lowercase letter
    # - At least one uppercase letter
    # - At least one number

    lowercase = "abcdefghijklmnopqrstuvwxyz"
    uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    numbers = "0123456789"
    all_chars = lowercase <> uppercase <> numbers

    # Ensure we have at least one of each required type
    password_chars = [
      String.at(lowercase, :rand.uniform(String.length(lowercase)) - 1),
      String.at(uppercase, :rand.uniform(String.length(uppercase)) - 1),
      String.at(numbers, :rand.uniform(String.length(numbers)) - 1)
    ]

    # Fill the rest to make it 12 characters total
    remaining = 12 - length(password_chars)

    random_chars =
      for _ <- 1..remaining do
        String.at(all_chars, :rand.uniform(String.length(all_chars)) - 1)
      end

    # Combine and shuffle
    (password_chars ++ random_chars)
    |> Enum.shuffle()
    |> Enum.join()
  end
end
