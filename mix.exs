defmodule EdgeCommander.Mixfile do
  use Mix.Project

  def project do
    [
      app: :edge_commander,
      version: "0.0.1",
      elixir: "~> 1.4",
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
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:comeonin, "~> 3.0"},
      {:dotenv, "~> 2.1.0"},
      {:httpoison, "~> 0.13.0"},
      {:quantum, ">= 2.1.0"},
      {:timex, "~> 3.0"},
      {:floki, "~> 0.18"},
      {:calendar, "~> 0.17.2"},
      {:con_cache, "~> 0.12.1"},
      {:mailgun, github: "evercam/mailgun"},
      {:sshex, "2.2.1"},
      {:phoenix_swagger, "~> 0.7.0"},
      {:ex_json_schema, "~> 0.5"}, # optional
      {:uuid, "~> 1.1"}
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
      "test": ["ecto.create --quiet", "ecto.migrate", "test"],
      "swagger": ["phx.swagger.generate priv/static/swagger.json --router EdgeCommander.Router --endpoint EdgeCommander.Endpoint"]
    ]
  end
end
