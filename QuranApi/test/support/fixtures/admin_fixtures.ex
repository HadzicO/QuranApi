defmodule QuranApi.AdminFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `QuranApi.Admin` context.
  """

  import QuranApi.AuthFixtures

  @doc """
  Generate a revision.
  """
  def revision_fixture(attrs \\ %{}) do
    user = Map.get(attrs, :user) || user_fixture()

    {:ok, revision} =
      attrs
      |> Map.drop([:user])
      |> Enum.into(%{
        entity_type: "translation",
        entity_id: 1,
        field_name: "text",
        old_value: %{"text" => "Old translation"},
        new_value: %{"text" => "New translation"},
        changes: %{"text" => "New translation"},
        reason: "Improved accuracy",
        status: "draft",
        user_id: user.id
      })
      |> QuranApi.Admin.create_revision()

    revision
  end

  @doc """
  Generate a notification.
  """
  def notification_fixture(attrs \\ %{}) do
    user = Map.get(attrs, :user) || user_fixture()

    {:ok, notification} =
      attrs
      |> Map.drop([:user])
      |> Enum.into(%{
        user_id: user.id,
        type: "translation_submitted",
        title: "Test Notification",
        message: "This is a test notification",
        entity_type: "revision",
        entity_id: 1,
        read: false
      })
      |> QuranApi.Admin.create_notification()

    notification
  end

  @doc """
  Generate an API key.
  """
  def api_key_fixture(attrs \\ %{}) do
    user = Map.get(attrs, :user) || user_fixture()

    {:ok, api_key, _plain_key} =
      attrs
      |> Map.drop([:user])
      |> Enum.into(%{
        user_id: user.id,
        name: "Test API Key",
        key_hash: :crypto.hash(:sha256, "test_key_#{System.unique_integer([:positive])}"),
        expires_at: DateTime.add(DateTime.utc_now(), 30, :day)
      })
      |> QuranApi.Admin.create_api_key()

    api_key
  end
end
