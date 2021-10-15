defmodule Plumbapius.Plug.SendToSentryValidationError do
  @behaviour Plug

  alias Plumbapius.Request
  alias Plumbapius.Response
  alias Plumbapius.AbstractPlug

  @impl Plug
  defdelegate init(options), to: AbstractPlug

  @impl Plug
  def call(conn, opts, plug_module \\ AbstractPlug, sentry \\ Sentry) do
    plug_module.call(
      conn,
      opts,
      fn error_msg, conn -> handle_request_error(error_msg, conn, sentry) end,
      fn error_msg, conn -> handle_response_error(error_msg, conn, sentry) end
    )
  end

  defp handle_request_error(%Request.ErrorDescription{} = error_message, conn, sentry) do
    sentry.capture_message("Plumbapius.RequestError: #{inspect(error_message)}")
    conn
  end

  defp handle_response_error(%Response.ErrorDescription{} = error_message, conn, sentry) do
    sentry.capture_message("Plumbapius.ResponseError: #{inspect(error_message)}")
    conn
  end
end
