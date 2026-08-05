defmodule QuranApiWeb.Admin.UserJSON do
  @moduledoc """
  Renders user responses.
  """

  def index(%{users: users}) do
    %{data: Enum.map(users, &user_data/1)}
  end

  def show(%{user: user}) do
    %{data: user_data(user)}
  end

  defp user_data(user) do
    %{
      id: user.id,
      email: user.email,
      name: build_name(user),
      role: user.role,
      status: user.status,
      first_name: user.first_name,
      last_name: user.last_name,
      last_login_at: user.last_login_at,
      last_login_ip: user.last_login_ip,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }
  end

  defp build_name(user) do
    case {user.first_name, user.last_name} do
      {nil, nil} -> nil
      {first, nil} -> first
      {nil, last} -> last
      {first, last} -> "#{first} #{last}"
    end
  end
end
