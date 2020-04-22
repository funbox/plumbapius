defmodule Mix.Tasks.Plumbapius.SetupDocsTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  alias Mix.Tasks.Plumbapius.SetupDocs

  defmodule Helper do
    def run_crafter(apib_filepath), do: send(self(), {{:run_crafter_called, "#{apib_filepath}"}, 0})

    def run_tomograph(json_filepath), do: send(self(), {{:run_tomograph_called, "#{json_filepath}"}, 0})
  end

  describe "run/1" do

    test "runs run_crafter and run_tomograph with default param" do
      SetupDocs.run(["-f", "./.apib/api.apib"], &Helper.run_crafter/1, &Helper.run_tomograph/1)

      assert_received {{:run_crafter_called, "./.apib/api.apib"}, 0}
      assert_received {{:run_tomograph_called, "doc.json"}, 0}
    end

    test "runs run_crafter and run_tomograph with custom json filepath" do
      SetupDocs.run(["-f", "./.apib/api.apib", "-i", "priv/doc.json"], &Helper.run_crafter/1, &Helper.run_tomograph/1)

      assert_received {{:run_crafter_called, "./.apib/api.apib"}, 0}
      assert_received {{:run_tomograph_called, "priv/doc.json"}, 0}
    end

    test "exit error with no --from arg given" do
      halt = fn val -> {:halt, val} end

      assert capture_io(fn ->
        assert {:halt, 1} == SetupDocs.run([], &Helper.run_crafter/1, &Helper.run_tomograph/1, halt)
      end) =~ "- missing required options: --from(-f)"
    end
  end
end