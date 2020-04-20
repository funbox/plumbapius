defmodule Mix.Tasks.Plumbapius.GetDocs do
  @moduledoc """
    Clones repository from git_clone_uri into .apib folder if .apib folder does not exist.
    Otherwise updates local .apib/ repository.

    #Usage
    ```
       mix plumbapius.get_docs ssh://git@git.funbox.ru/gc/ghetto-auth-apib.git
    ```
  """

  use Mix.Task

  require Logger

  @apib_workdir ".apib"

  @spec run(list(String.t())) :: term
  def run([git_clone_uri]) do
    Logger.info("Running get_docs command with uri #{git_clone_uri}")

    unless File.exists?(@apib_workdir) do
      clone_repo(git_clone_uri)
    else
      update_repo()
    end

    update_gitignore()
  end

  defp clone_repo(git_clone_uri) do
    case System.cmd("git", ["clone", git_clone_uri, @apib_workdir]) do
      {_, 0} ->
        Logger.info("Repository has been cloned successfully")

      error ->
        Logger.error(inspect(error))
    end
  end

  defp update_gitignore do
    unless File.stream!(".gitignore") |> Enum.any?(fn str -> str == @apib_workdir end) do
      Logger.info("Updating .gitignore file")
      {:ok, file} = File.open(".gitignore", [:append])
      IO.binwrite(file, @apib_workdir <> "\n")
      File.close(file)
      Logger.info(".gitignore file has been updated successfully")
    end
  end

  defp update_repo do
    with {_, 0} <- System.cmd("git", ["-C", @apib_workdir, "fetch", "origin", "master"]),
         {_, 0} <- System.cmd("git", ["-C", @apib_workdir, "reset", "--hard", "origin/master"]),
         {_, 0} <- System.cmd("git", ["-C", @apib_workdir, "clean", "-ffdx"]) do
      Logger.info("Repository has been updated successfully")
    else
      error ->
        Logger.error(inspect(error))
    end
  end
end
