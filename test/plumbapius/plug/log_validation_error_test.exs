defmodule Plumbapius.Plug.LogValidationErrorTest do
  use ExUnit.Case
  import ExUnit.CaptureLog

  alias Plumbapius.Plug.LogValidationError
  alias FakePlugImplementation, as: Helper

  test "init delegates to base Plug and returns options" do
    init_options = [json_schema: File.read!("test/fixtures/correct_schema.json")]

    assert LogValidationError.init(init_options).schema == Helper.options().schema
  end

  test "log request error" do
    assert capture_log(fn ->
             LogValidationError.call(:request_error, nil, FakePlug)
           end) =~ ~r/Plumbapius.RequestError/
  end

  test "log response error" do
    assert capture_log(fn ->
             LogValidationError.call(:response_error, nil, FakePlug)
           end) =~ ~r/Plumbapius.ResponseError/
  end

  test "log request and response error" do
    logs =
      capture_log(fn ->
        LogValidationError.call(:both, nil, FakePlug)
      end)

    assert logs =~ ~r/Plumbapius.RequestError/
    assert logs =~ ~r/Plumbapius.ResponseError/
  end

  test "plug return call result" do
    assert LogValidationError.call(nil, nil, FakePlug) == {:ok, :called}
  end
end
