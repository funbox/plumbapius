defmodule Mix.Tasks.Plumbapius.SetupDocs do
  @moduledoc """
    Transform .apib file from the given path into doc.json using:
    - crafter (https://bb.funbox.ru/projects/APIB/repos/crafter)
    - tomograph (https://github.com/funbox/tomograph)

    You should install those tools:
    > npm config set registry https://npm.funbox.io/
    > npm login
    > npm install -g npx
    > gem install tomograph

    #Usage
    ```
      mix plumbapius.setup_docs --from ./.apib/api.apib --into doc.json
    ```
  """

  use Mix.Task

  require Logger

  @temp_yml_filepath "doc.yml"
  @json_filepath "doc.json"

  @spec run([String.t()]) :: term
  def run(argv) do
    with %{options: options} <- params() |> Optimus.parse!(argv),
         {_, 0} <- run_crafter(options.apib_filepath),
         {_, 0} <- run_tomograph() do
      Logger.info("Docs have been parsed successfully into #{@json_filepath}")
    else
      error ->
        Logger.error(inspect(error))
    end

    File.rm(@temp_yml_filepath)
  end

  defp run_crafter(apib_filepath) do
    System.cmd("npx", ["@funbox/crafter", apib_filepath],
      into: File.stream!(@temp_yml_filepath)
    )
  end

  defp run_tomograph do
    {cmd, params} = case System.cmd("bundle", ["info", "tomograph"], [stderr_to_stdout: true]) do
      {_, 0} ->
        {"bundle", ["exec", "tomograph", "-d", "crafter", "--exclude-description", @temp_yml_filepath, @json_filepath]}
      _ ->
        {"tomograph", ["-d", "crafter", "--exclude-description", @temp_yml_filepath, @json_filepath]}
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
        json_filepath: [
          value_name: "JSON_FILEPATH",
          short: "-i",
          long: "--into",
          help: "Output .json filepath",
          required: true
        ]
      ]
    )
  end
end
