defmodule Mix.Tasks.Admin.Setup do
  @moduledoc """
  Creates an initial admin user for the Quran API admin panel.

  Usage:
    mix admin.setup

  Or with custom credentials:
    mix admin.setup --email admin@example.com --password SecurePass123
  """
  use Mix.Task

  alias QuranApi.Auth

  @shortdoc "Creates an initial admin user"
  def run(args) do
    Mix.Task.run("app.start")

    {opts, _, _} =
      OptionParser.parse(args,
        strict: [email: :string, password: :string, firstname: :string, lastname: :string]
      )

    email = Keyword.get(opts, :email) || prompt("Admin email")
    password = Keyword.get(opts, :password) || prompt_password("Admin password")
    first_name = Keyword.get(opts, :firstname) || prompt("First name")
    last_name = Keyword.get(opts, :lastname) || prompt("Last name")

    case Auth.create_user(%{
           email: email,
           password: password,
           role: "admin",
           first_name: first_name,
           last_name: last_name
         }) do
      {:ok, user} ->
        Mix.shell().info("✓ Admin user created successfully!")
        Mix.shell().info("")
        Mix.shell().info("Email: #{user.email}")
        Mix.shell().info("Role: #{user.role}")
        Mix.shell().info("")
        Mix.shell().info("You can now login at: POST /admin/login")

      {:error, changeset} ->
        Mix.shell().error("✗ Failed to create admin user:")
        errors = format_errors(changeset)
        Mix.shell().error(errors)
    end
  end

  defp prompt(message) do
    Mix.shell().prompt("#{message}: ") |> String.trim()
  end

  defp prompt_password(message) do
    password = Mix.shell().prompt("#{message}: ") |> String.trim()
    confirm = Mix.shell().prompt("Confirm password: ") |> String.trim()

    if password == confirm do
      password
    else
      Mix.shell().error("Passwords do not match. Try again.")
      prompt_password(message)
    end
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.map_join("\n", fn {field, errors} ->
      "  #{field}: #{Enum.join(errors, ", ")}"
    end)
  end
end
