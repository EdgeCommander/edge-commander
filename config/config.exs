# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :phoenix, :json_library, Jason

# General application configuration
config :edge_commander,
  ecto_repos: [EdgeCommander.Repo]

# Configures the endpoint
config :edge_commander, EdgeCommanderWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "QIzlsUtXDn1OBO2YQh1t1V+EPkPhMMkE2Sj5quMQx7fgRrkbQM8MDSusDzDFRyb4",
  render_errors: [view: EdgeCommanderWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: EdgeCommander.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.

config :edge_commander, EdgeCommander.Scheduler,
  jobs: [
    # Every minute
    # {"* * * * *",      {EdgeCommander.Portable, :start_porting, []}},
    # Every 15 minutes
    {"@daily",   {EdgeCommander.Raid, :check_failed_drives, []}},
    # Every 6 hour on zero minute
    # {"0 */6 * * *",  {ThreeScraper.Cookie, :email_alert, [0]}},
    {"*/5 * * * *",      {EdgeCommanderWeb.BatteryReadingController, :get_all_batteries, []}},
  ]

config :edge_commander, :phoenix_swagger,
  swagger_files: %{
    "assets/public/swagger.json" => [
      router: EdgeCommanderWeb.Router,     # phoenix routes will be converted to swagger paths
      endpoint: EdgeCommanderWeb.Endpoint  # (optional) endpoint config used to set host, port and https schemes.
    ]
  }

config :edge_commander, EdgeCommander.Accounts.Guardian,
issuer: "edge_commander",
secret_key: "svZjRMUUkbxdPoxbgTd7jAjFihOc5B8kHkpzIju1AZF3hbzdvMMpY+hq/6Y2aFPK"

config :edge_commander, EdgeCommander.Accounts.Pipeline,
  module: EdgeCommander.Accounts.Guardian,
  error_handler: EdgeCommander.Accounts.ErrorHandler

config :geoip, provider: :ipstack, use_https: :false, api_key: System.get_env("IPSTACK_ACCESS_KEY")

config :edge_commander, EdgeCommander.Scheduler,
  debug_logging: false

import_config "#{Mix.env}.exs"
