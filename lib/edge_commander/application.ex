defmodule EdgeCommander.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      {ConCache,[ttl_check_interval: :timer.seconds(0.1), global_ttl: :timer.seconds(2.5), name: :cache]},
      Supervisor.child_spec({ConCache, [ttl_check_interval: :timer.seconds(1), global_ttl: :timer.hours(1), name: :current_nvr_status]}, id: :current_nvr_status),
      Supervisor.child_spec({ConCache, [ttl_check_interval: :timer.seconds(1), global_ttl: :timer.hours(1), name: :users]}, id: :users),
      # Start the Ecto repository
      supervisor(EdgeCommander.Repo, []),
      # Start the endpoint when the application starts
      supervisor(EdgeCommanderWeb.Endpoint, []),
      worker(EdgeCommander.Scheduler, []),
      ThreeScraper.Scraper
      # ThreeScraper.Cookie,
      # EdgeCommander.ThreeScraper
      # Start your own worker by calling: EdgeCommander.Worker.start_link(arg1, arg2, arg3)
      # worker(EdgeCommander.Worker, [arg1, arg2, arg3]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: EdgeCommander.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    EdgeCommanderWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
