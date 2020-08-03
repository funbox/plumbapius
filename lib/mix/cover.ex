defmodule Mix.Tasks.Plumbapius.Cover do
  use Mix.Task

  @shortdoc "Runs tests and prints uncovered cases"
  @preferred_cli_env "test"

  alias Plumbapius.Coverage.DefaultCoverageTracker
  alias Plumbapius.Plug.Options
  alias Plumbapius.Coverage.Report

  @impl Mix.Task
  def run(args, _halt \\ &System.halt/1) do
    cli = Optimus.parse!(cli_description(), args)

    cli.options[:schema_path]
    |> load_schema()
    |> DefaultCoverageTracker.start_link()

    Application.put_env(:plumbapius, :coverage_tracker, DefaultCoverageTracker)

    Mix.Task.run("test")

    report = DefaultCoverageTracker.coverage_report()

    report
    |> render_report()
    |> IO.puts()

    check_coverage(Report.coverage(report), cli.options[:min_coverage])
  end

  defp load_schema(schema_data) do
    schema_data = File.read!(schema_data)
    Options.new(json_schema: schema_data).schema
  end

  def check_coverage(real_coverage, min_coverage) when real_coverage < min_coverage do
    IO.puts("\nERROR! min coverage of #{min_coverage * 100}% is required")
    exit({:shutdown, 1})
  end

  def check_coverage(_real_coverage, _min_coverage) do
    :ok
  end

  defp render_report(%Report{} = report) do
    [
      "\n",
      "Covered cases:\n\n",
      render_interactions(report.covered, "✔ "),
      "\n",
      "Missed cases: \n\n",
      render_interactions(report.missed, "✖ "),
      "\n",
      "Coverage: #{render_coverage(report)}%"
    ]
  end

  defp render_coverage(report) do
    Float.round(Report.coverage(report) * 100, 1)
  end

  defp render_interactions(interactions, prefix) do
    Enum.map(interactions, &render_interaction(&1, prefix))
  end

  defp render_interaction({request, response}, prefix) do
    [prefix, String.pad_trailing(request.method, 5), " ", request.original_path, " ", to_string(response.status), "\n"]
  end

  defp cli_description do
    Optimus.new!(
      name: "cover",
      description: @shortdoc,
      allow_unknown_args: false,
      parse_double_dash: true,
      options: [
        schema_path: [
          value_name: "SCHEMA",
          short: "-s",
          long: "--schema",
          help: "Path to json schema file",
          required: true
        ],
        min_coverage: [
          value_name: "MIN_COVERAGE",
          long: "--min-coverage",
          help: "task fails when coverage is beneath given treshold",
          default: 0.0,
          parser: :float,
          required: false
        ]
      ]
    )
  end
end
