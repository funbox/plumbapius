defmodule Mix.Tasks.SetupDocs do
  use Mix.Task

  require Logger

  @apib_workdir ".apib"
  @yml_filepath ".apib/doc.yml"
  @json_filepath "doc.json"

  # Tools
  # https://bb.funbox.ru/projects/APIB/repos/crafter
  # https://github.com/funbox/tomograph

  # Prepare
  # npm config set registry https://npm.funbox.io/
  # npm login
  # npm install -g npx
  # npm install -g @funbox/crafter
  # gem install tomograph
  # .tool-versions ruby 2.5.1
  # git clone ssh://git@git.funbox.ru/gc/ghetto-auth-apib.git .apib/
  # npx crafter .apib/api.apib > .apib/doc.yml
  # tomograph -d crafter --exclude-description .apib/doc.yml doc.json

  # Use
  # mix setup_docs gc ghetto-auth api.apib

  @spec run(list(String.t())) :: :ok | {:error, atom}
  def run([repo_name, project_name, apib_filename]) do
    repo_url = "ssh://git@git.funbox.ru/#{repo_name}/#{project_name}-apib.git"
    apib_filepath = Path.join(@apib_workdir, apib_filename)

    clean(@apib_workdir)
    File.mkdir!(@apib_workdir)
    update_docs(repo_url, apib_filepath)
    clean(@apib_workdir)
  end

  defp update_docs(repo_url, apib_filepath) do
    with {_, 0} <- System.cmd("git", ["clone", repo_url, @apib_workdir]),
         {_, 0} <-
           System.cmd("npx", ["crafter", apib_filepath], into: File.stream!(@yml_filepath)),
         {_, 0} <-
           System.cmd("tomograph", [
             "-d",
             "crafter",
             "--exclude-description",
             @yml_filepath,
             @json_filepath
           ]) do
      Logger.info("Docs have been upgraded successfully")
    else
      error ->
        Logger.error(inspect(error))
    end
  end

  defp clean(apib_folder_path) do
    IO.puts("Deleting not required files...")
    File.rm_rf(apib_folder_path)
    File.rm(@yml_filepath)
  end
end
