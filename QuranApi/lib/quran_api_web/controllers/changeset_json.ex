defmodule QuranApiWeb.ChangesetJSON do
  @moduledoc """
  JSON rendering for changeset errors.
  """

  @doc """
  Renders changeset errors.
  """
  def render("error.json", %{changeset: changeset}) do
    %{
      error: %{
        code: "validation_error",
        message: "Validation failed",
        details: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
      }
    }
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end
