defmodule Plumbapius.MixProject do
  use Mix.Project

  def project do
    [
      app: :plumbapius,
      version: "0.1.0",
      elixir: "~> 1.10.0-otp-22",
      deps: deps(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      preferred_cli_env: [
        cover: :test,
        "cover.detail": :test,
        "cover.html": :test,
        "cover.filter": :test,
        "cover.lint": :test,
        dialyzer: :test,
        arch_test: :test
      ],
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 3.1"},
      {:ex_json_schema, "~> 0.7.3"},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.2", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.11", only: :test},
      {:excoveralls_linter, "~> 0.0.2", only: :test},
      {:plug_cowboy, "~> 2.0"}
    ]
  end

  defp aliases do
    [
      test: ["test --no-start"],
      cover: ["coveralls --sort cov:desc --umbrella"],
      "cover.lint": ["coveralls.lint --missed-lines-threshold=2 --required-file-coverage=0.9"],
      "cover.html": ["coveralls.html --umbrella"],
      "cover.detail": ["coveralls.detail --umbrella --filter"],
      arch_test: ["run --no-start test/arch_test.exs"]
    ]
  end
end
