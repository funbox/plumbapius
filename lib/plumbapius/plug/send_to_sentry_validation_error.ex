defmodule Plumbapius.Plug.SendToSentryValidationError do
  @behaviour Plug

  alias Plumbapius.Request
  alias Plumbapius.Response

  defdelegate init(options), to: Plumbapius.Plug

  @impl Plug
  def call(conn, opts, plug_module \\ Plumbapius.Plug, sentry \\ Sentry) do
    plug_module.call(
      conn,
      opts,
      fn error_msg -> handle_request_error(error_msg, sentry) end,
      fn error_msg -> handle_response_error(error_msg, sentry) end
    )
  end

  defp handle_request_error(%Request.ErrorDescription{} = error_message, sentry) do
    sentry.capture_message("Plumbapius.RequestError: #{inspect(error_message)}")
  end

  defp handle_response_error(%Response.ErrorDescription{} = error_message, sentry) do
    sentry.capture_message("Plumbapius.ResponseError: #{inspect(error_message)}")
  end
end
