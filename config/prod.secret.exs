use Mix.Config

# In this file, we keep production configuration that
# you'll likely want to automate and keep away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or yourself later on).
config :edge_commander, EdgeCommanderWeb.Endpoint,
  secret_key_base: "rSFkOSk50/ZCNdN++7fnfCnrSA3fdpr7wJvBrnYAs2mY2ladAcT3nxSMLJ6lL13c"

# Configure your database
config :edge_commander, EdgeCommander.Repo,
  url: System.get_env("DATABASE_URL"),
  socket_options: [keepalive: true],
  timeout: 60_000,
  pool_timeout: 60_000,
  pool_size: 80,
  lazy: false,
  ssl: true
