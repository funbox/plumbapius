defmodule Plumbapius.Plug.SendToSentryValidationErrorTest do
  use ExUnit.Case, async: true

  alias Plumbapius.Plug.SendToSentryValidationError

  test "send RequestError into sentry when request invalid" do
    SendToSentryValidationError.call(:request_error, nil, FakePlug, FakeSentry)

    assert_received :sentry_called_request_error
  end

  test "send ResponseError into sentry when response invalid" do
    SendToSentryValidationError.call(:response_error, nil, FakePlug, FakeSentry)

    assert_received :sentry_called_response_error
  end

  test "send both errors into sentry when both invalid" do
    SendToSentryValidationError.call(:both, nil, FakePlug, FakeSentry)

    assert_received :sentry_called_request_error
    assert_received :sentry_called_response_error
  end

  test "plug return call result" do
    assert SendToSentryValidationError.call(nil, nil, FakePlug) == {:ok, :called}
  end
end
