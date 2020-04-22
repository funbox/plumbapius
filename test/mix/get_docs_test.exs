defmodule Mix.Tasks.Plumbapius.GetDocsTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  alias Mix.Tasks.Plumbapius.GetDocs

  defmodule Helper do
    def update_repo(uri, local_folder, branch), do: send(self(), {:update_repo_called, "#{uri},#{local_folder},#{branch}"})

    def update_gitignore(local_folder), do: send(self(), {:update_gitignore_called, "#{local_folder}"})
  end

  describe "run/1" do

    test "runs update_repo and update_gitignore with default params" do
      GetDocs.run(["-c", "ssh://apib.git"], &Helper.update_repo/3, &Helper.update_gitignore/1)

      assert_received {:update_repo_called, "ssh://apib.git,.apib,master"}
      assert_received {:update_gitignore_called, ".apib"}
    end

    test "runs update_repo and update_gitignore with custom branch" do
      GetDocs.run(["-c", "ssh://apib.git", "-b", "feature"], &Helper.update_repo/3, &Helper.update_gitignore/1)

      assert_received {:update_repo_called, "ssh://apib.git,.apib,feature"}
      assert_received {:update_gitignore_called, ".apib"}
    end

    test "runs update_repo and update_gitignore with custom local folder" do
      GetDocs.run(["-c", "ssh://apib.git", "-d", ".custom_folder"], &Helper.update_repo/3, &Helper.update_gitignore/1)

      assert_received {:update_repo_called, "ssh://apib.git,.custom_folder,master"}
      assert_received {:update_gitignore_called, ".custom_folder"}
    end

    test "runs update_repo and update_gitignore with custom local folder and branch" do
      GetDocs.run(["-c", "ssh://apib.git", "-d", ".custom_folder", "-b", "feature"], &Helper.update_repo/3, &Helper.update_gitignore/1)

      assert_received {:update_repo_called, "ssh://apib.git,.custom_folder,feature"}
      assert_received {:update_gitignore_called, ".custom_folder"}
    end

    test "exit error with no --clone arg given" do
      halt = fn val -> {:halt, val} end

      assert capture_io(fn ->
        assert {:halt, 1} == GetDocs.run([], &Helper.update_repo/3, &Helper.update_gitignore/1, halt)
      end) =~ "- missing required options: --clone(-c)"
    end
  end
end
