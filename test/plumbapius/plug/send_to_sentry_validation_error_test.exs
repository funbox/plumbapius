defmodule Plumbapius.Plug.SendToSentryValidationErrorTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog

  alias Plumbapius.Plug.SendToSentryValidationError

  test "send RequestError into sentry when request invalid" do
    assert capture_log(fn ->
             SendToSentryValidationError.call(:request_error, nil, FakePlug, FakeSentry)
           end) =~ "capture_message called for RequestError"
  end

  test "send ResponseError into sentry when response invalid" do
    assert capture_log(fn ->
             SendToSentryValidationError.call(:response_error, nil, FakePlug, FakeSentry)
           end) =~ "capture_message called for ResponseError"
  end

  test "send both errors into sentry when both invalid" do
    logs =
      capture_log(fn -> SendToSentryValidationError.call(:both, nil, FakePlug, FakeSentry) end)

    assert logs =~ "capture_message called for RequestError"
    assert logs =~ "capture_message called for ResponseError"
  end

  test "plug return call result" do
    assert SendToSentryValidationError.call(nil, nil, FakePlug) == {:ok, :called}
  end
end
