defmodule Plumbapius.Plug.LogValidationErrorTest do
  use ExUnit.Case
  import ExUnit.CaptureLog

  alias Plumbapius.Plug.LogValidationError

  test "log request error" do
    assert capture_log(fn ->
             LogValidationError.call(:request_error, nil, FakePlug)
           end) =~
             "[debug] Plumbapius.RequestError: %{body: %{\"foo\" => \"bar\"}, error: [{\"Type mismatch. Expected Number but got String.\", \"#/msisdn\"}], method: \"get\", path: \"/fake/path\"}"
  end

  test "log response error" do
    assert capture_log(fn ->
             LogValidationError.call(:response_error, nil, FakePlug)
           end) =~
             "[debug] Plumbapius.ResponseError: %{body: %{\"bar\" => \"foo\"}, error: \"invalid\", request: %{method: \"get\", path: \"/fake/path\"}, status: 200}"
  end

  test "log request and response error" do
    logs =
      capture_log(fn ->
        LogValidationError.call(nil, nil, FakePlug)
      end)

    logs =~
      "[debug] Plumbapius.RequestError: %{body: %{\"foo\" => \"bar\"}, error: [{\"Type mismatch. Expected Number but got String.\", \"#/msisdn\"}], method: \"get\", path: \"/fake/path\"}"

    logs =~
      "[debug] Plumbapius.ResponseError: %{body: %{\"bar\" => \"foo\"}, error: \"invalid\", request: %{method: \"get\", path: \"/fake/path\"}, status: 200}"
  end
end
