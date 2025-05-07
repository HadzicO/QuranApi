defmodule QuranApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      QuranApiWeb.Telemetry,
      QuranApi.Repo,
      {DNSCluster, query: Application.get_env(:quran_api, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: QuranApi.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: QuranApi.Finch},
      # Start a worker by calling: QuranApi.Worker.start_link(arg)
      # {QuranApi.Worker, arg},
      # Start to serve requests, typically the last entry
      QuranApiWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: QuranApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    QuranApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
