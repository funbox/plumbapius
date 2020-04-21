defmodule Mix.Tasks.Plumbapius.GetDocs do
  @moduledoc """
    Work with git repo and store it into required folder

    #Usage
    ```
       mix plumbapius.get_docs -c ssh://git@git.funbox.ru/gc/ghetto-auth-apib.git -d ./path/to/put/repo -b branch-name
    ```
  """

  use Mix.Task

  require Logger

  @default_apib_workdir ".apib"
  @default_branch "master"

  @spec run([String.t()]) :: term
  def run(argv) do
    %{options: options} = params()
                          |> Optimus.parse!(argv)

    update_repo(options)
    update_gitignore(options.local_stock_folder)
  end

  defp update_repo(options) do
    unless File.exists?(options.local_stock_folder) do
      clone_repo(options.git_clone_uri, options.local_stock_folder, options.branch)
    else
      update_repo(options.local_stock_folder, options.branch)
    end
  end

  defp update_repo(local_git_folder, branch) do
    Logger.info("Updating #{local_git_folder} repository with branch #{branch}")
    with {_, 0} <- System.cmd("git", ["-C", local_git_folder, "fetch", "origin", branch]),
         {_, 0} <- System.cmd("git", ["-C", local_git_folder, "reset", "--hard", "origin/#{branch}"]),
         {_, 0} <- System.cmd("git", ["-C", local_git_folder, "clean", "-ffdx"]) do
      Logger.info("Repository has been updated successfully")
    else
      error ->
        raise RuntimeError, inspect(error)
    end
  end

  defp clone_repo(git_uri, local_folder, branch) do
    Logger.info("Cloning #{git_uri} repository into #{local_folder} with branch #{branch}")
    with {_, 0} <- System.cmd("git", ["clone", git_uri, local_folder]),
         {_, 0} <- System.cmd("git", ["checkout", branch]) do
      Logger.info("Repository has been cloned successfully")
    else
      error ->
        raise RuntimeError, inspect(error)
    end
  end

  defp update_gitignore(local_stock_folder) do
    unless File.stream!(".gitignore") |> Enum.any?(&String.starts_with?(&1, local_stock_folder)) do
      Logger.info("Updating .gitignore file")
      {:ok, file} = File.open(".gitignore", [:append])
      IO.binwrite(file, local_stock_folder <> "\n")
      File.close(file)
      Logger.info(".gitignore file has been updated successfully")
    end
  end

  defp params do
    Optimus.new!(
      name: "get_docs",
      description: "Git repositories assistant",
      version: "0.1.0",
      author: "Funbox",
      about: "Utility for downloading and updating apib repository",
      allow_unknown_args: false,
      parse_double_dash: true,
      options: [
        git_clone_uri: [
          value_name: "GIT_CLONE_URI",
          short: "-c",
          long: "--clone",
          help: "Clone URI of apib repository",
          required: true
        ],
        local_stock_folder: [
          value_name: "LOCAL_STOCK_DIRECTORY",
          short: "-d",
          long: "--directory",
          help: "Local directory to stock apib repository",
          required: false,
          default: @default_apib_workdir
        ],
        branch: [
          value_name: "BRANCH",
          short: "-b",
          long: "--branch",
          help: "Required branch in apib repository",
          required: false,
          default: @default_branch
        ],
      ]
    )
  end
end
