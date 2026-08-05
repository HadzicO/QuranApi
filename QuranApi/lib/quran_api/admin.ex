defmodule QuranApi.Admin do
  @moduledoc """
  The Admin context handles administrative operations.
  """
  import Ecto.Query, warn: false
  alias QuranApi.Repo
  alias QuranApi.Admin.{ApiKey, AuditLog, Notification, Revision}
  alias QuranApi.Auth.User

  # ===========================
  # Audit Logs
  # ===========================

  @doc """
  Creates an audit log entry.
  """
  @spec create_audit_log(map()) :: {:ok, AuditLog.t()} | {:error, Ecto.Changeset.t()}
  def create_audit_log(attrs) do
    %AuditLog{}
    |> AuditLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Lists audit logs with optional filters.
  """
  @spec list_audit_logs(keyword()) :: [AuditLog.t()]
  def list_audit_logs(opts \\ []) do
    user_id = Keyword.get(opts, :user_id)
    entity_type = Keyword.get(opts, :entity_type)
    action = Keyword.get(opts, :action)
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 50)

    AuditLog
    |> maybe_filter_by_user(user_id)
    |> maybe_filter_by_entity_type(entity_type)
    |> maybe_filter_by_action(action)
    |> order_by([a], desc: a.inserted_at)
    |> preload(:user)
    |> limit(^per_page)
    |> offset(^((page - 1) * per_page))
    |> Repo.all()
  end

  @doc """
  Logs an action to the audit log.
  """
  @spec log_action(User.t() | nil, String.t(), String.t(), integer() | nil, map(), map()) ::
          {:ok, AuditLog.t()} | {:error, Ecto.Changeset.t()}
  def log_action(user, action, entity_type, entity_id, changes, metadata \\ %{}) do
    create_audit_log(%{
      user_id: user && user.id,
      action: action,
      entity_type: entity_type,
      entity_id: entity_id,
      changes: changes,
      ip_address: Map.get(metadata, :ip_address),
      user_agent: Map.get(metadata, :user_agent)
    })
  end

  # ===========================
  # Revisions
  # ===========================

  @doc """
  Gets a single revision.
  """
  @spec get_revision(integer()) :: Revision.t() | nil
  def get_revision(id), do: Repo.get(Revision, id)

  @doc """
  Lists revisions with optional filters.
  """
  @spec list_revisions(keyword()) :: [Revision.t()]
  def list_revisions(opts \\ []) do
    user_id = Keyword.get(opts, :user_id)
    entity_type = Keyword.get(opts, :entity_type)
    entity_id = Keyword.get(opts, :entity_id)
    status = Keyword.get(opts, :status)
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 20)

    Revision
    |> maybe_filter_revision_by_user(user_id)
    |> maybe_filter_by_entity_type(entity_type)
    |> maybe_filter_revision_by_entity_id(entity_id)
    |> maybe_filter_revision_by_status(status)
    |> order_by([r], desc: r.inserted_at)
    |> preload([:user, :reviewed_by])
    |> limit(^per_page)
    |> offset(^((page - 1) * per_page))
    |> Repo.all()
  end

  @doc """
  Creates a revision.
  """
  @spec create_revision(map()) :: {:ok, Revision.t()} | {:error, Ecto.Changeset.t()}
  def create_revision(attrs) do
    %Revision{}
    |> Revision.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Submits a revision for review.
  """
  @spec submit_revision(Revision.t()) :: {:ok, Revision.t()} | {:error, Ecto.Changeset.t()}
  def submit_revision(%Revision{} = revision) do
    revision
    |> Revision.submit_changeset()
    |> Repo.update()
  end

  @doc """
  Approves a revision.
  """
  @spec approve_revision(Revision.t(), User.t() | integer(), String.t() | nil) ::
          {:ok, Revision.t()} | {:error, Ecto.Changeset.t()}
  def approve_revision(revision, reviewer, notes \\ nil)

  def approve_revision(%Revision{} = revision, %User{} = reviewer, notes) do
    revision
    |> Revision.approve_changeset(reviewer.id, notes)
    |> Repo.update()
  end

  # Overload for when reviewer_id is passed as integer
  def approve_revision(%Revision{} = revision, reviewer_id, notes) when is_integer(reviewer_id) do
    case QuranApi.Auth.get_user(reviewer_id) do
      nil -> {:error, :reviewer_not_found}
      reviewer -> approve_revision(revision, reviewer, notes)
    end
  end

  @doc """
  Rejects a revision.
  """
  @spec reject_revision(Revision.t(), User.t() | integer(), String.t() | nil) ::
          {:ok, Revision.t()} | {:error, Ecto.Changeset.t()}
  def reject_revision(revision, reviewer, notes \\ nil)

  def reject_revision(%Revision{} = revision, %User{} = reviewer, notes) do
    revision
    |> Revision.reject_changeset(reviewer.id, notes)
    |> Repo.update()
  end

  # Overload for when reviewer_id is passed as integer
  def reject_revision(%Revision{} = revision, reviewer_id, notes) when is_integer(reviewer_id) do
    case QuranApi.Auth.get_user(reviewer_id) do
      nil -> {:error, :reviewer_not_found}
      reviewer -> reject_revision(revision, reviewer, notes)
    end
  end

  @doc """
  Publishes an approved revision.
  """
  @spec publish_revision(Revision.t()) ::
          {:ok, Revision.t()} | {:error, Ecto.Changeset.t() | :not_approved}
  def publish_revision(%Revision{status: :approved} = revision) do
    revision
    |> Revision.publish_changeset()
    |> Repo.update()
  end

  def publish_revision(_), do: {:error, :not_approved}

  # ===========================
  # Notifications
  # ===========================

  @doc """
  Gets a single notification.
  """
  @spec get_notification(integer()) :: Notification.t() | nil
  def get_notification(id), do: Repo.get(Notification, id)

  @doc """
  Lists notifications for a user.
  """
  @spec list_user_notifications(integer(), keyword()) :: [Notification.t()]
  def list_user_notifications(user_id, opts \\ []) do
    read = Keyword.get(opts, :read)
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 20)

    Notification
    |> where([n], n.user_id == ^user_id)
    |> maybe_filter_by_read_status(read)
    |> order_by([n], desc: n.inserted_at)
    |> limit(^per_page)
    |> offset(^((page - 1) * per_page))
    |> Repo.all()
  end

  @doc """
  Counts user notifications with optional filters.
  """
  @spec count_user_notifications(integer(), keyword()) :: integer()
  def count_user_notifications(user_id, opts \\ []) do
    read = Keyword.get(opts, :read)

    Notification
    |> where([n], n.user_id == ^user_id)
    |> maybe_filter_by_read_status(read)
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Creates a notification.
  """
  @spec create_notification(map()) :: {:ok, Notification.t()} | {:error, Ecto.Changeset.t()}
  def create_notification(attrs) do
    %Notification{}
    |> Notification.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Marks a notification as read.
  """
  @spec mark_notification_read(Notification.t()) ::
          {:ok, Notification.t()} | {:error, Ecto.Changeset.t()}
  def mark_notification_read(%Notification{} = notification) do
    notification
    |> Notification.read_changeset()
    |> Repo.update()
  end

  @doc """
  Marks all notifications as read for a user.
  """
  @spec mark_all_notifications_read(integer()) :: {integer(), nil}
  def mark_all_notifications_read(user_id) do
    from(n in Notification,
      where: n.user_id == ^user_id and n.read == false,
      update: [set: [read: true, read_at: ^DateTime.utc_now()]]
    )
    |> Repo.update_all([])
  end

  @doc """
  Notifies admins about an event.
  """
  @spec notify_admins(String.t(), String.t(), String.t(), map()) :: :ok
  def notify_admins(type, title, message, metadata \\ %{}) do
    admin_ids =
      from(u in User, where: u.role == :admin and u.status == :active, select: u.id)
      |> Repo.all()

    Enum.each(admin_ids, fn admin_id ->
      create_notification(%{
        user_id: admin_id,
        type: type,
        title: title,
        message: message,
        related_entity_type: Map.get(metadata, :entity_type),
        related_entity_id: Map.get(metadata, :entity_id)
      })
    end)

    :ok
  end

  @doc """
  Notifies a specific user.
  """
  @spec notify_user(integer(), String.t(), String.t(), String.t(), map()) ::
          {:ok, Notification.t()} | {:error, Ecto.Changeset.t()}
  def notify_user(user_id, type, title, message, metadata \\ %{}) do
    create_notification(%{
      user_id: user_id,
      type: type,
      title: title,
      message: message,
      related_entity_type: Map.get(metadata, :entity_type),
      related_entity_id: Map.get(metadata, :entity_id)
    })
  end

  # ===========================
  # API Keys
  # ===========================

  @doc """
  Gets a single API key.
  """
  @spec get_api_key(integer()) :: ApiKey.t() | nil
  def get_api_key(id), do: Repo.get(ApiKey, id) |> Repo.preload(:user)

  @doc """
  Gets an API key by hash.
  """
  @spec get_api_key_by_hash(String.t()) :: ApiKey.t() | nil
  def get_api_key_by_hash(key_hash), do: Repo.get_by(ApiKey, key_hash: key_hash)

  @doc """
  Lists API keys.
  """
  @spec list_api_keys(keyword()) :: [ApiKey.t()]
  def list_api_keys(opts \\ []) do
    user_id = Keyword.get(opts, :user_id)
    status = Keyword.get(opts, :status)

    ApiKey
    |> maybe_filter_api_key_by_user(user_id)
    |> maybe_filter_api_key_by_status(status)
    |> order_by([k], desc: k.inserted_at)
    |> preload(:user)
    |> Repo.all()
  end

  @doc """
  Creates an API key.
  """
  @spec create_api_key(map()) :: {:ok, ApiKey.t(), String.t()} | {:error, Ecto.Changeset.t()}
  def create_api_key(attrs) do
    changeset = ApiKey.changeset(%ApiKey{}, attrs)

    case Repo.insert(changeset) do
      {:ok, api_key} ->
        # Return the plain key only once during creation
        plain_key = Ecto.Changeset.get_change(changeset, :key)
        {:ok, api_key, plain_key}

      error ->
        error
    end
  end

  @doc """
  Updates an API key.
  """
  @spec update_api_key(ApiKey.t(), map()) :: {:ok, ApiKey.t()} | {:error, Ecto.Changeset.t()}
  def update_api_key(%ApiKey{} = api_key, attrs) do
    api_key
    |> Ecto.Changeset.cast(attrs, [:name, :description, :expires_at, :status])
    |> Repo.update()
  end

  @doc """
  Updates API key usage.
  """
  @spec update_api_key_usage(ApiKey.t(), String.t()) ::
          {:ok, ApiKey.t()} | {:error, Ecto.Changeset.t()}
  def update_api_key_usage(%ApiKey{} = api_key, ip_address) do
    api_key
    |> ApiKey.usage_changeset(ip_address)
    |> Repo.update()
  end

  @doc """
  Revokes an API key.
  """
  @spec revoke_api_key(ApiKey.t()) :: {:ok, ApiKey.t()} | {:error, Ecto.Changeset.t()}
  def revoke_api_key(%ApiKey{} = api_key) do
    api_key
    |> ApiKey.revoke_changeset()
    |> Repo.update()
  end

  @doc """
  Deletes an API key.
  """
  @spec delete_api_key(ApiKey.t()) :: {:ok, ApiKey.t()} | {:error, Ecto.Changeset.t()}
  def delete_api_key(%ApiKey{} = api_key) do
    Repo.delete(api_key)
  end

  # ===========================
  # Dashboard Statistics
  # ===========================

  @doc """
  Gets dashboard statistics.
  """
  @spec get_dashboard_stats() :: map()
  def get_dashboard_stats do
    %{
      users: %{
        total: count_users(),
        active: count_active_users(),
        admins: count_users_by_role("admin"),
        editors: count_users_by_role("editor"),
        readonly: count_users_by_role("readonly")
      },
      revisions: %{
        total: count_revisions(),
        pending: count_pending_reviews(),
        approved: count_revisions_by_status(:approved),
        rejected: count_revisions_by_status(:rejected),
        published: count_published_revisions()
      },
      notifications: %{
        total: count_all_notifications(),
        unread: count_unread_notifications()
      },
      api_keys: %{
        total: count_api_keys(),
        active: count_active_api_keys()
      }
    }
  end

  # Private helper functions

  defp count_users, do: Repo.aggregate(User, :count, :id)

  defp count_users_by_role(role),
    do: Repo.aggregate(from(u in User, where: u.role == ^role), :count, :id)

  defp count_active_users,
    do: Repo.aggregate(from(u in User, where: u.status == :active), :count, :id)

  defp count_revisions, do: Repo.aggregate(Revision, :count, :id)

  defp count_revisions_by_status(status),
    do: Repo.aggregate(from(r in Revision, where: r.status == ^status), :count, :id)

  defp count_pending_reviews,
    do: Repo.aggregate(from(r in Revision, where: r.status == :pending_review), :count, :id)

  defp count_published_revisions,
    do: Repo.aggregate(from(r in Revision, where: r.status == :published), :count, :id)

  defp count_all_notifications, do: Repo.aggregate(Notification, :count, :id)

  defp count_unread_notifications,
    do: Repo.aggregate(from(n in Notification, where: n.read == false), :count, :id)

  defp count_api_keys, do: Repo.aggregate(ApiKey, :count, :id)

  defp count_active_api_keys,
    do: Repo.aggregate(from(k in ApiKey, where: k.status == "active"), :count, :id)

  defp maybe_filter_by_user(query, nil), do: query
  defp maybe_filter_by_user(query, user_id), do: where(query, [a], a.user_id == ^user_id)

  defp maybe_filter_by_entity_type(query, nil), do: query
  defp maybe_filter_by_entity_type(query, type), do: where(query, [a], a.entity_type == ^type)

  defp maybe_filter_by_action(query, nil), do: query
  defp maybe_filter_by_action(query, action), do: where(query, [a], a.action == ^action)

  defp maybe_filter_revision_by_user(query, nil), do: query
  defp maybe_filter_revision_by_user(query, user_id), do: where(query, [r], r.user_id == ^user_id)

  defp maybe_filter_revision_by_entity_id(query, nil), do: query

  defp maybe_filter_revision_by_entity_id(query, entity_id),
    do: where(query, [r], r.entity_id == ^entity_id)

  defp maybe_filter_revision_by_status(query, nil), do: query
  defp maybe_filter_revision_by_status(query, status), do: where(query, [r], r.status == ^status)

  defp maybe_filter_by_read_status(query, nil), do: query
  defp maybe_filter_by_read_status(query, read), do: where(query, [n], n.read == ^read)

  defp maybe_filter_api_key_by_user(query, nil), do: query
  defp maybe_filter_api_key_by_user(query, user_id), do: where(query, [k], k.user_id == ^user_id)

  defp maybe_filter_api_key_by_status(query, nil), do: query
  defp maybe_filter_api_key_by_status(query, status), do: where(query, [k], k.status == ^status)
end
