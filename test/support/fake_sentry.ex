defmodule FakeSentry do
  require Logger

  @spec capture_message(any) :: :ok
  def capture_message("Plumbapius.RequestError" <> _other = _msg),
    do: send(self(), :sentry_called_request_error)

  def capture_message("Plumbapius.ResponseError" <> _other = _msg),
    do: send(self(), :sentry_called_response_error)
end
