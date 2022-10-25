defmodule SteamIntersection.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      SteamIntersection.Repo,
      # Start the Telemetry supervisor
      SteamIntersectionWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: SteamIntersection.PubSub},
      # Start the Endpoint (http/https)
      {SiteEncrypt.Phoenix, SteamIntersectionWeb.Endpoint},
      # Start a worker by calling: SteamIntersection.Worker.start_link(arg)
      # {SteamIntersection.Worker, arg}
      {Cachex, name: :app},
      {Task.Supervisor, name: SteamIntersection.TaskSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SteamIntersection.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SteamIntersectionWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
