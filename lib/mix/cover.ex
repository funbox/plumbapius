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

    report =
      DefaultCoverageTracker.coverage_report()
      |> Report.ignore(ignore_patterns())

    coverage = coverage(report, cli.flags)

    report
    |> render_report(coverage, cli.flags)
    |> IO.puts()

    check_coverage(coverage, cli.options[:min_coverage])
  end

  defp load_schema(schema_data) do
    schema_data = File.read!(schema_data)
    Options.new(json_schema: schema_data).schema
  end

  defp coverage(report, options) do
    if options[:multi_choices] do
      Report.multi_choice_coverage(report)
    else
      Report.coverage(report)
    end
  end

  defp check_coverage(real_coverage, min_coverage) when real_coverage < min_coverage do
    IO.puts("\nERROR! min coverage of #{min_coverage * 100}% is required")
    exit({:shutdown, 1})
  end

  defp check_coverage(_real_coverage, _min_coverage) do
    :ok
  end

  defp render_report(%Report{} = report, coverage, options) do
    [
      "\n",
      "Covered cases:\n\n",
      render_interactions(report.covered, "✔ ", options),
      "\n",
      "Missed cases: \n\n",
      render_interactions(report.missed, "✖ ", options),
      if(options[:multi_choices], do: render_multi_reports(report.interaction_reports), else: ""),
      "\n",
      "Coverage: #{render_coverage(coverage)}%"
    ]
  end

  defp render_coverage(coverage) do
    Float.round(coverage * 100, 1)
  end

  defp render_multi_reports(reports) do
    [
      "\n",
      "MISSED oneOfs and enums:\n\n",
      Enum.map(reports, &render_multi_choices/1),
      "\n"
    ]
  end

  defp render_multi_choices(report) do
    Enum.map(report.missed_multi_choices, &render_missed_choice(report.interaction, &1))
  end

  defp render_missed_choice(interaction, {path, schema}) do
    [
      render_interaction_header(interaction, "✖ "),
      " ",
      Enum.join(path, "."),
      "\n",
      inspect(schema),
      "\n\n"
    ]
  end

  defp render_interactions(interactions, prefix, options) do
    Enum.map(interactions, &render_interaction(&1, prefix, options))
  end

  defp render_interaction({request, response}, prefix, options) do
    header = render_interaction_header({request, response}, prefix) ++ ["\n"]

    if options[:verbose] do
      header ++ ["\n", details(request, response), "\n\n"]
    else
      header
    end
  end

  defp render_interaction_header({request, response}, prefix) do
    [
      prefix,
      String.pad_trailing(request.method, 5),
      " ",
      request.original_path,
      " ",
      to_string(response.status)
    ]
  end

  defp details(request, response) do
    [
      "REQUEST:\n",
      request_bodies_schemas(request),
      "\n",
      "RESPONSE:\n",
      inspect(response.body.schema)
    ]
  end

  defp request_bodies_schemas(request) do
    schemas =
      request.bodies
      |> Enum.map(fn body -> inspect(body.schema) end)
      |> Enum.join(", ")

    "[#{schemas}]"
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
      ],
      flags: [
        verbose: [
          value_name: "VERBOSE",
          short: "-v",
          help: "prints bodies of requests/responses",
          default: false,
          required: false
        ],
        multi_choices: [
          value_name: "MULTI_CHOICES",
          short: "-m",
          help: "computes coverage of oneOfs and enums",
          default: false,
          required: false
        ]
      ]
    )
  end

  defp ignore_patterns do
    Application.get_env(:plumbapius, :ignore_coverage, [])
  end
end
