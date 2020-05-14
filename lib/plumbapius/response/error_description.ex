defmodule Plumbapius.Response.ErrorDescription do
  alias alias Plumbapius.ErrorFormat

  defstruct [:request, :status, :body, :error]

  @type t :: %__MODULE__{
          request: %{method: String.t(), path: String.t()},
          status: non_neg_integer,
          body: iodata,
          error: any
        }

  @spec new(Plug.Conn.t(), any) :: t
  def new(conn, error) do
    %__MODULE__{
      request: %{
        method: conn.method,
        path: conn.request_path
      },
      status: conn.status,
      body: conn.resp_body,
      error: error
    }
  end

  defimpl String.Chars do
    def to_string(descr) do
      "Unexpected RESPONSE to #{descr.request.method |> String.upcase()} #{descr.request.path}; " <>
        "status: #{descr.status}; body: `#{ErrorFormat.body(descr.body)}`; " <>
        "error: #{ErrorFormat.schema_error(descr.error)}"
    end
  end
end
