defmodule Mix.Tasks.Plumbapius.SetupDocs do
  @moduledoc """
    Transforms .apib file from the given path into doc.json using:
    - drafter (https://github.com/apiaryio/drafter)
    - tomograph (https://github.com/funbox/tomograph)

    You should install following tools:
    > drafter
    > gem install tomograph # or add to Gemfile

    #Usage
    ```
      mix plumbapius.setup_docs --from ./.apib/api.apib --into doc.json
    ```
  """

  @shortdoc "Transforms apib docs to json schema"

  use Mix.Task

  require Logger

  @temp_yml_filepath "doc.yml"
  @default_json_filepath "doc.json"

  @impl Mix.Task
  def run(argv, run_apib_tool \\ nil, run_tomograph \\ &run_tomograph/2, halt \\ &System.halt/1) do
    with %{options: options} <- Optimus.parse!(params(), argv, halt),
         {_, 0} <- (run_apib_tool || apib_tool_runner(options.apib_tool)).(options.apib_filepath),
         {_, 0} <- run_tomograph.(options.json_filepath, options.apib_tool) do
      File.rm(@temp_yml_filepath)
      Logger.info("Docs have been parsed successfully into #{options.json_filepath}")
    else
      error ->
        File.rm(@temp_yml_filepath)
        error
    end
  end

  defp apib_tool_runner("drafter"), do: &run_drafter/1
  defp apib_tool_runner("crafter"), do: &run_crafter/1

  defp apib_tool_runner(tool) do
    raise "unsupported apib tool:#{tool}"
  end

  defp run_drafter(apib_filepath) do
    System.cmd("drafter", [apib_filepath], into: File.stream!(@temp_yml_filepath))
  catch
    :error, :enoent -> raise "no drafter executable is available in PATH"
  end

  defp run_crafter(apib_filepath) do
    System.cmd("npx", ["@funbox/crafter", apib_filepath], into: File.stream!(@temp_yml_filepath))
  end

  defp run_tomograph(json_filepath, apib_tool) do
    {cmd, params} =
      case System.cmd("bundle", ["info", "tomograph"], stderr_to_stdout: true) do
        {_, 0} ->
          {"bundle",
           [
             "exec",
             "tomograph",
             "-d",
             apib_tool,
             "--exclude-description",
             @temp_yml_filepath,
             json_filepath
           ]}

        _ ->
          {"tomograph", ["-d", apib_tool, "--exclude-description", @temp_yml_filepath, json_filepath]}
      end

    System.cmd(cmd, params)
  end

  defp params do
    Optimus.new!(
      name: "setup_docs",
      description: "Apib docs setup assistant",
      version: "0.1.0",
      author: "Funbox",
      about: "Utility for transform .apib into .json doc",
      allow_unknown_args: false,
      parse_double_dash: true,
      options: [
        apib_filepath: [
          value_name: "APIB_FILEPATH",
          short: "-f",
          long: "--from",
          help: "Filepath of .apib docs",
          required: true
        ],
        apib_tool: [
          value_name: "APIB_TOOL",
          long: "--apib-tool",
          help: "Apib parser used",
          default: "drafter"
        ],
        json_filepath: [
          value_name: "JSON_FILEPATH",
          short: "-i",
          long: "--into",
          help: "Output .json filepath",
          required: false,
          default: @default_json_filepath
        ]
      ]
    )
  end
end
