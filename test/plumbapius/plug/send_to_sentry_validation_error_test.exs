defmodule Plumbapius.Plug.SendToSentryValidationErrorTest do
  use ExUnit.Case, async: true

  alias Plumbapius.Plug.SendToSentryValidationError

  test "send RequestError into sentry when request invalid" do
    SendToSentryValidationError.call(:request_error, nil, FakePlug)
  end

  test "send ResponseError into sentry when response invalid" do
    SendToSentryValidationError.call(:response_error, nil, FakePlug)
  end

  test "send both errors into sentry when both invalid" do
    SendToSentryValidationError.call(nil, nil, FakePlug)
  end
end
