defmodule Plumbapius.Plug.RaiseValidationError do
  @behaviour Plug

  alias Plumbapius.Request
  alias Plumbapius.Response
  alias Plumbapius.AbstractPlug

  defdelegate init(options), to: AbstractPlug

  defmodule RequestError do
    defexception [:description]

    @impl true
    def message(exception) do
      "Plumpabius.RequestError: #{exception.description}"
    end
  end

  defmodule ResponseError do
    defexception [:description]

    @impl true
    def message(exception) do
      "Plumpabius.ResponseError: #{exception.description}"
    end
  end

  @impl Plug
  def call(conn, opts, plug_module \\ AbstractPlug) do
    plug_module.call(conn, opts, &handle_request_error/2, &handle_response_error/2)
  end

  defp handle_request_error(%Request.ErrorDescription{} = description, _conn) do
    raise %RequestError{description: description}
  end

  defp handle_response_error(%Response.ErrorDescription{} = description, _conn) do
    raise %ResponseError{description: description}
  end
end
