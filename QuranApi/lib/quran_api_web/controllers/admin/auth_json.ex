defmodule QuranApiWeb.Admin.AuthJSON do
  @moduledoc """
  Renders auth responses.
  """

  def login(%{user: user, tokens: tokens}) do
    Map.merge(
      %{
        access_token: tokens.access_token,
        refresh_token: tokens.refresh_token,
        user: user_data(user)
      },
      %{}
    )
  end

  def user(%{user: user}) do
    %{data: user_data(user)}
  end

  defp user_data(user) do
    %{
      id: user.id,
      email: user.email,
      role: user.role,
      status: user.status,
      first_name: user.first_name,
      last_name: user.last_name,
      last_login_at: user.last_login_at,
      inserted_at: user.inserted_at
    }
  end
end
