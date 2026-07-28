defmodule QuranApiWeb.Admin.RevisionController do
  use QuranApiWeb, :controller

  alias QuranApi.{Admin, Repo}

  action_fallback QuranApiWeb.FallbackController

  plug QuranApiWeb.Plugs.EnsureRole, ["admin", "editor"]

  @doc """
  List revisions - GET /admin/revisions
  """
  def index(conn, params) do
    page = Map.get(params, "page", "1") |> String.to_integer()
    per_page = Map.get(params, "per_page", "20") |> String.to_integer()
    status = Map.get(params, "status")
    entity_type = Map.get(params, "entity_type")

    revisions =
      Admin.list_revisions(
        page: page,
        per_page: per_page,
        status: status,
        entity_type: entity_type
      )

    conn
    |> render(:index, revisions: revisions)
  end

  @doc """
  Get single revision - GET /admin/revisions/:id
  """
  def show(conn, %{"id" => id}) do
    case Admin.get_revision(id) do
      nil -> {:error, :not_found}
      revision -> render(conn, :show, revision: Repo.preload(revision, [:user, :reviewed_by]))
    end
  end

  @doc """
  Create revision - POST /admin/revisions
  """
  def create(conn, %{"revision" => revision_params}) do
    current_user = Guardian.Plug.current_resource(conn)

    revision_params = Map.put(revision_params, "user_id", current_user.id)

    with {:ok, revision} <- Admin.create_revision(revision_params) do
      # Notify admins about new submission
      Admin.notify_admins(
        "#{revision_params["entity_type"]}_submitted",
        "New #{revision_params["entity_type"]} submission",
        "#{current_user.email} has submitted a new #{revision_params["entity_type"]} for review.",
        %{entity_type: "revision", entity_id: revision.id}
      )

      conn
      |> put_status(:created)
      |> render(:show, revision: revision)
    end
  end

  @doc """
  Submit revision for review - POST /admin/revisions/:id/submit
  """
  def submit(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)

    with revision when not is_nil(revision) <- Admin.get_revision(id),
         true <- revision.user_id == current_user.id or current_user.role == :admin,
         {:ok, updated_revision} <- Admin.submit_revision(revision) do
      # Notify admins
      Admin.notify_admins(
        "#{revision.entity_type}_submitted",
        "Revision submitted for review",
        "A #{revision.entity_type} revision has been submitted for review.",
        %{entity_type: "revision", entity_id: revision.id}
      )

      conn
      |> render(:show, revision: updated_revision)
    else
      nil ->
        {:error, :not_found}

      false ->
        {:error, :forbidden}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, extract_changeset_error(changeset)}

      error ->
        error
    end
  end

  @doc """
  Approve revision - POST /admin/revisions/:id/approve
  """
  def approve(conn, %{"id" => id, "notes" => notes}) do
    current_user = Guardian.Plug.current_resource(conn)

    # Only admins can approve
    if current_user.role != :admin do
      {:error, :forbidden}
    else
      with revision when not is_nil(revision) <- Admin.get_revision(id),
           {:ok, updated_revision} <- Admin.approve_revision(revision, current_user, notes) do
        # Notify the submitter
        if revision.user_id do
          Admin.notify_user(
            revision.user_id,
            "#{revision.entity_type}_approved",
            "Your #{revision.entity_type} was approved",
            "Your #{revision.entity_type} submission has been approved by #{current_user.email}.",
            %{entity_type: "revision", entity_id: revision.id}
          )
        end

        # Log action
        Admin.log_action(
          current_user,
          "approve_revision",
          "revision",
          revision.id,
          %{
            notes: notes
          },
          %{}
        )

        conn
        |> render(:show, revision: updated_revision)
      else
        nil ->
          {:error, :not_found}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:error, extract_changeset_error(changeset)}

        error ->
          error
      end
    end
  end

  def approve(conn, %{"id" => id}), do: approve(conn, %{"id" => id, "notes" => nil})

  @doc """
  Reject revision - POST /admin/revisions/:id/reject
  """
  def reject(conn, %{"id" => id, "reason" => reason}) do
    current_user = Guardian.Plug.current_resource(conn)

    # Only admins can reject
    if current_user.role != :admin do
      {:error, :forbidden}
    else
      with revision when not is_nil(revision) <- Admin.get_revision(id),
           {:ok, updated_revision} <- Admin.reject_revision(revision, current_user, reason) do
        # Notify the submitter
        if revision.user_id do
          Admin.notify_user(
            revision.user_id,
            "#{revision.entity_type}_rejected",
            "Your #{revision.entity_type} was rejected",
            "Your #{revision.entity_type} submission has been rejected. #{reason}",
            %{entity_type: "revision", entity_id: revision.id}
          )
        end

        # Log action
        Admin.log_action(
          current_user,
          "reject_revision",
          "revision",
          revision.id,
          %{
            notes: reason
          },
          %{}
        )

        conn
        |> render(:show, revision: updated_revision)
      else
        nil ->
          {:error, :not_found}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:error, extract_changeset_error(changeset)}

        error ->
          error
      end
    end
  end

  def reject(conn, %{"id" => id}), do: reject(conn, %{"id" => id, "reason" => nil})

  @doc """
  Publish revision - POST /admin/revisions/:id/publish
  """
  def publish(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)

    # Only admins can publish
    if current_user.role != :admin do
      {:error, :forbidden}
    else
      with revision when not is_nil(revision) <- Admin.get_revision(id),
           {:ok, updated_revision} <- Admin.publish_revision(revision) do
        # Log action
        Admin.log_action(current_user, "publish_revision", "revision", revision.id, %{}, %{})

        conn
        |> render(:show, revision: updated_revision)
      else
        nil -> {:error, :not_found}
        {:error, :not_approved} -> {:error, "Only approved revisions can be published"}
        {:error, %Ecto.Changeset{}} -> {:error, :unprocessable_entity}
      end
    end
  end

  # Helper function to extract the first error message from a changeset
  defp extract_changeset_error(changeset) do
    case changeset.errors do
      [{_field, {message, _}} | _] -> message
      _ -> "Validation failed"
    end
  end
end
