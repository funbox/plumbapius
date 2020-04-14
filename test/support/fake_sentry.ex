defmodule FakeSentry do
  require Logger

  @spec capture_message(any) :: :ok
  def capture_message("Plumbapius.RequestError" <> _other = _msg),
    do: Logger.debug("capture_message called for RequestError")

  def capture_message("Plumbapius.ResponseError" <> _other = _msg),
    do: Logger.debug("capture_message called for ResponseError")
end
