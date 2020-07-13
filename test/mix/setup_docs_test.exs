defmodule Mix.Tasks.Plumbapius.SetupDocsTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  alias Mix.Tasks.Plumbapius.SetupDocs

  describe "#run" do
    test "runs run_crafter and run_tomograph with default param" do
      SetupDocs.run(["-f", "./.apib/api.apib"], &run_crafter/1, &run_tomograph/2)

      assert_received {{:run_crafter_called, "./.apib/api.apib"}, 0}
      assert_received {{:run_tomograph_called, "doc.json"}, 0}
    end

    test "runs run_crafter and run_tomograph with custom json filepath" do
      SetupDocs.run(["-f", "./.apib/api.apib", "-i", "priv/doc.json"], &run_crafter/1, &run_tomograph/2)

      assert_received {{:run_crafter_called, "./.apib/api.apib"}, 0}
      assert_received {{:run_tomograph_called, "priv/doc.json"}, 0}
    end

    test "exit error with no --from arg given" do
      halt = fn val -> {:halt, val} end

      assert capture_io(fn ->
               assert {:halt, 1} == SetupDocs.run([], &run_crafter/1, &run_tomograph/2, halt)
             end) =~ "- missing required options: --from(-f)"
    end

    defp run_crafter(apib_filepath), do: send(self(), {{:run_crafter_called, "#{apib_filepath}"}, 0})

    defp run_tomograph(json_filepath, _apib_tool), do: send(self(), {{:run_tomograph_called, "#{json_filepath}"}, 0})
  end
end
