defmodule Mix.Tasks.Plumbapius.CoverTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  test "it reports covered and missed interactions" do
    output = run_cover()

    assert output =~ ~r/POST\s+\/sessions 401/
    assert output =~ ~r/POST\s+\/sessions 201/
    assert output =~ ~r/GET\s+\/users 200/

    assert output =~ "Coverage: 0.0%"
  end

  test "it reports covered and missed interactions in verbose mode" do
    output = run_cover(["-v"])

    assert output =~ ~r/POST\s+\/sessions 401/
    assert output =~ ~r/#{Regex.escape(~s{"$schema" => "http://json-schema.org/draft-04/schema#"})}/
  end

  test "it returns successfully when coverage is ok" do
    output = run_cover(["--min-coverage=0"])
    assert output =~ "Coverage: 0.0%"
  end

  test "it fails when coverage is below given min value" do
    assert catch_exit(run_cover(["--min-coverage=100"])) == {:shutdown, 1}
  end

  defp run_cover(args \\ []) do
    capture_io(fn ->
      Mix.Task.rerun("plumbapius.cover", ["-s", "test/fixtures/correct_schema.json"] ++ args)
    end)
  end
end
