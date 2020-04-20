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
      mix plumbapius.setup_docs ./.apib/api.apib
    ```
  """

  use Mix.Task

  require Logger

  @temp_yml_filepath "doc.yml"
  @json_filepath "doc.json"

  @spec run(list(String.t())) :: term
  def run([apib_filepath]) do
    with {_, 0} <-
           System.cmd("npx", ["@funbox/crafter", apib_filepath],
             into: File.stream!(@temp_yml_filepath)
           ),
         {_, 0} <-
           System.cmd("tomograph", [
             "-d",
             "crafter",
             "--exclude-description",
             @temp_yml_filepath,
             @json_filepath
           ]) do
      Logger.info("Docs have been parsed successfully into #{@json_filepath}")
    else
      error ->
        Logger.error(inspect(error))
    end

    File.rm!(@temp_yml_filepath)
  end
end
