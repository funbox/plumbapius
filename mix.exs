defmodule Plumbapius.MixProject do
  use Mix.Project

  def project do
    [
      app: :plumbapius,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:plug_cowboy, "~> 2.0"}
    ]
  end
end
