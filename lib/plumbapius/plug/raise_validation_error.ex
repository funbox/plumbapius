defmodule Plumbapius.Plug.RaiseValidationError do
  @behaviour Plug

  alias Plumbapius.Request
  alias Plumbapius.Response
  alias Plumbapius.AbstractPlug

  defdelegate init(options), to: AbstractPlug

  defmodule RequestError do
    defexception [:error_message]

    @impl true
    def message(exception) do
      "Plumpabius.RequestError: #{inspect(exception.error_message)}"
    end
  end

  defmodule ResponseError do
    defexception [:error_message]

    @impl true
    def message(exception) do
      "Plumpabius.ResponseError: #{inspect(exception.error_message)}"
    end
  end

  @impl Plug
  def call(conn, opts, plug_module \\ AbstractPlug) do
    plug_module.call(conn, opts, &handle_request_error/1, &handle_response_error/1)
  end

  defp handle_request_error(%Request.ErrorDescription{} = error_message) do
    raise %RequestError{error_message: error_message}
  end

  defp handle_response_error(%Response.ErrorDescription{} = error_message) do
    raise %ResponseError{error_message: error_message}
  end
end
