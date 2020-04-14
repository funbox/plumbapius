defmodule Plumbapius.Plug.LogValidationErrorTest do
  use ExUnit.Case
  import ExUnit.CaptureLog

  alias Plumbapius.Plug.LogValidationError

  test "log request error" do
    assert capture_log(fn ->
             LogValidationError.call(:request_error, nil, FakePlug)
           end) =~
             ~s([warn]  Plumbapius.RequestError: %Plumbapius.Request.ErrorDescription{body: %{"foo" => "bar"}, error: [{"Type mismatch. Expected Number but got String.", "#/msisdn"}], method: "get", path: "/fake/path"})
  end

  test "log response error" do
    assert capture_log(fn ->
             LogValidationError.call(:response_error, nil, FakePlug)
           end) =~
             ~s([warn]  Plumbapius.ResponseError: %Plumbapius.Response.ErrorDescription{body: ["{", "foo", ":", "bar", "}"], error: "invalid", request: %{method: "get", path: "/fake/path"}, status: 200})
  end

  test "log request and response error" do
    logs =
      capture_log(fn ->
        LogValidationError.call(:both, nil, FakePlug)
      end)

    assert logs =~
             ~s([warn]  Plumbapius.RequestError: %Plumbapius.Request.ErrorDescription{body: %{"foo" => "bar"}, error: [{"Type mismatch. Expected Number but got String.", "#/msisdn"}], method: "get", path: "/fake/path"})

    assert logs =~
             ~s([warn]  Plumbapius.ResponseError: %Plumbapius.Response.ErrorDescription{body: ["{", "foo", ":", "bar", "}"], error: "invalid", request: %{method: "get", path: "/fake/path"}, status: 200})
  end

  test "plug return call result" do
    assert LogValidationError.call(nil, nil, FakePlug) == {:ok, :called}
  end
end
