defmodule Plumbapius.Plug.LogValidationError do
  @behaviour Plug

  require Logger

  alias Plumbapius.Request
  alias Plumbapius.Response
  alias Plumbapius.AbstractPlug

  defdelegate init(options), to: AbstractPlug

  @impl Plug
  def call(conn, opts, plug_module \\ AbstractPlug) do
    plug_module.call(conn, opts, &handle_request_error/2, &handle_response_error/2)
  end

  defp handle_request_error(%Request.ErrorDescription{} = error_message, conn) do
    Logger.warn("Plumbapius.RequestError: #{inspect(error_message)}")
    conn
  end

  defp handle_response_error(%Response.ErrorDescription{} = error_message, conn) do
    Logger.warn("Plumbapius.ResponseError: #{inspect(error_message)}")
    conn
  end
end
