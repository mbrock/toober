defmodule Tooba.MixProject do
  use Mix.Project

  def project do
    [
      app: :tooba,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Tooba.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:membrane_core, "~> 0.12.3"},
      {:membrane_opus_plugin, "~> 0.18.0"},
      {:membrane_matroska_plugin, "~> 0.4.0"},
      {:membrane_portaudio_plugin, "~> 0.17.3"},
      {:websockex, "~> 0.4.3"},
      # tesla: HTTP client with middleware
      {:tesla, "~> 1.8.0"},
      # hackney: recommended HTTP client for Tesla
      {:hackney, "~> 1.17.4"},
      # req: HTTP client
      {:req, "~> 0.4.0"},
      # kino: Livebook widgets
      {:kino, "~> 0.11.1"},
      # tortoise: MQTT client
      {:tortoise, "~> 0.10"},
      # rdf: RDF graph suite
      {:rdf, "~> 1.1"},
      {:rdf_xml, "~> 1.0"},
      {:json_ld, "~> 0.3"},
      {:elixir_uuid, "~> 1.2"},
      # Phoenix dependencies
      {:phoenix, "~> 1.7.10"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.20.1"},
      # floki: HTML parser
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.2"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},
      # swoosh: email client
      {:swoosh, "~> 1.3"},
      # finch: HTTP client
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:plug_cowboy, "~> 2.5"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end
