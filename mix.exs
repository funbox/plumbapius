defmodule Plumbapius.MixProject do
  use Mix.Project

  def project do
    [
      app: :plumbapius,
      version: "0.13.0",
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
      description: description(),
      dialyzer:
        [
          plt_add_apps: [:mix]
        ] ++ dialyzer()
    ]
  end

  defp package do
    [
      name: :plumbapius,
      files: ["lib", "mix.exs", "README*", "LICENSE"],
      maintainers: ["Miroslav Malkin"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => "https://github.com/funbox/plumbapius"
      }
    ]
  end

  defp description() do
    "Plugs and tools for HTTP request/response validation according to API Blueprint specs"
  end

  defp elixirc_paths(env) when env in [:test], do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp dialyzer do
    case System.get_env("DIALYZER_PLT_FILE") do
      nil ->
        []

      file ->
        [plt_file: {:no_warn, file}]
    end
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
      {:optimus, "~> 0.1.9"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
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
