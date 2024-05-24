defmodule UrFUAPI.MixProject do
  use Mix.Project

  def project do
    [
      app: :urfu_api,
      version: "0.1.0",
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [
        plt_add_apps: [:mix],
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        ignore_warnings: ".dialyzer_ignore.exs"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {UrFUAPI.Application, []}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tz, "~> 0.26.5"},
      {:joken, "~> 2.5"},
      {:jason, ">= 1.0.0"},
      {:finch, "~> 0.18"},
      {:floki, "~> 0.35.0"},
      {:exconstructor, github: "txssu/exconstructor"},
      {:typedstruct, "~> 0.5.2"},
      {:publicist, "1.1.0"},
      {:mimic, "~> 1.7", only: :test},
      {:credo, "~> 1.7.3", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4.3", only: [:dev, :test], runtime: false},
      {:mix_audit, "~> 2.1.2", only: [:dev, :test], runtime: false},
      {:styler, "~> 0.11.9", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      ci: [
        "compile --all-warnings --warnings-as-errors",
        "format --check-formatted",
        "credo --strict",
        "deps.audit",
        "dialyzer"
      ]
    ]
  end
end
