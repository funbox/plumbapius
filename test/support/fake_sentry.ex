defmodule FakeSentry do
  @spec capture_message(any) :: :ok
  def capture_message("Plumbapius.RequestError" <> _other = _msg), do: :ok

  def capture_message("Plumbapius.ResponseError" <> _other = _msg), do: :ok
end
