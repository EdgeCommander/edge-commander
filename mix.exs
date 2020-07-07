defmodule EdgeCommander.Mixfile do
  use Mix.Project

  def project do
    [
      app: :edge_commander,
      version: "0.0.1",
      elixir: "~> 1.7.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {EdgeCommander.Application, []},
      extra_applications: [:logger, :runtime_tools, :con_cache]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.1"},
      {:ecto_sql, "~> 3.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:postgrex, ">= 0.14.1"},
      {:phoenix_html, "~> 2.13"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.18.0"},
      {:plug_cowboy, "~> 2.0"},
      {:comeonin, "~> 5.1"},
      {:dotenv, "~> 3.0.0"},
      {:httpoison, "~> 1.5", override: true},
      {:quantum, "~> 2.3"},
      {:timex, "~> 3.4"},
      {:floki, "~> 0.27.0"},
      {:calendar, "~> 0.18.0"},
      {:con_cache, "~> 0.14.0"},
      {:swoosh, "~> 0.22"},
      {:phoenix_swoosh, "~> 0.2"},
      {:sshex, "2.2.1"},
      {:phoenix_swagger, github: "xerions/phoenix_swagger"},
      {:ex_json_schema, "~> 0.7.1"},
      {:uuid, "~> 1.1.8"},
      {:guardian, github: "ueberauth/guardian"},
      {:geoip, "~> 0.2.3"},
      {:browser, github: "danhper/elixir-browser"},
      {:bcrypt_elixir, "~> 2.0"},
      {:poison, "~> 4.0", override: true}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      swagger: ["phx.swagger.generate priv/static/swagger.json --router EdgeCommander.Router --endpoint EdgeCommander.Endpoint"]
    ]
  end
end
