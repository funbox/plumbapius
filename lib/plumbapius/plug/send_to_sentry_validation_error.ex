defmodule Plumbapius.Plug.SendToSentryValidationError do
  @behaviour Plug

  @sentry Application.get_env(:sentry, :module, Sentry)

  defdelegate init(options), to: Plumbapius.Plug

  @impl Plug
  def call(conn, opts, plug_module \\ Plumbapius.Plug) do
    plug_module.call(conn, opts, &handle_request_error/1, &handle_response_error/1)
  end

  defp handle_request_error(error_message) do
    @sentry.capture_message("Plumbapius.RequestError: #{inspect(error_message)}")
  end

  defp handle_response_error(error_message) do
    @sentry.capture_message("Plumbapius.ResponseError: #{inspect(error_message)}")
  end
end
