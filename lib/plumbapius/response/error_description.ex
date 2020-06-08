defmodule Plumbapius.Response.ErrorDescription do
  # credo:disable-for-this-file Credo.Check.Readability.Specs
  alias Plumbapius.{ErrorFormat, ConnHelper}

  defstruct [:request, :status, :content_type, :body, :error]

  @type t :: %__MODULE__{
          request: %{method: String.t(), path: String.t()},
          status: non_neg_integer,
          content_type: String.t() | nil,
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
      content_type: ConnHelper.get_resp_header(conn, "content-type"),
      body: conn.resp_body,
      error: error
    }
  end

  defimpl String.Chars do
    def to_string(descr) do
      [
        ["Unexpected RESPONSE to ", descr.request.method |> String.upcase(), " ", descr.request.path],
        ["status: ", ErrorFormat.status(descr.status)],
        ["content-type: ", ErrorFormat.content_type(descr.content_type)],
        ["body: ", "`", ErrorFormat.body(descr.body), "`"],
        ["error: ", ErrorFormat.schema_error(descr.error)]
      ]
      |> Enum.join("; ")
    end
  end
end
