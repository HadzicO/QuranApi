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
      String.replace(acc, "%{#{key}}", stringify_value(value))
    end)
  end

  # Helper to safely convert values to strings
  defp stringify_value(value) when is_list(value) do
    inspect(value)
  end

  defp stringify_value(value) when is_tuple(value) do
    inspect(value)
  end

  defp stringify_value(value) do
    to_string(value)
  end
end
