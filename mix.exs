defmodule Plumbapius.MixProject do
  use Mix.Project

  def project do
    [
      app: :plumbapius,
      version: "0.2.0",
      elixir: "~> 1.10.0",
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
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [tool: ExCoveralls],
      package: package(),
      description: "Plumbapius"
    ]
  end

  def package do
    [
      name: "plumbapius",
      licenses: ["proprietary"],
      links: %{funbox: "https://bb.funbox.ru/projects/APIB/repos/plumbapius/browse"}
    ]
  end

  defp elixirc_paths(env) when env in [:test], do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.2"},
      {:ex_json_schema, "~> 0.7.3"},
      {:plug, "~> 1.0"},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.2", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.11", only: :test},
      {:excoveralls_linter, "~> 0.0.2", only: :test},
      {:optimus, "~> 0.1.0"}
    ]
  end

  defp aliases do
    [
      cover: ["coveralls --sort cov:desc --umbrella"],
      "cover.lint": ["coveralls.lint --missed-lines-threshold=2 --required-file-coverage=0.9"],
      "cover.html": ["coveralls.html --umbrella"],
      "cover.detail": ["coveralls.detail --umbrella --filter"],
      arch_test: ["run --no-start test/arch_test.exs"]
    ]
  end
end
