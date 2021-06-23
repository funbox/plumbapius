defmodule Plumbapius.Response.ErrorDescription do
  # credo:disable-for-this-file Credo.Check.Readability.Specs
  alias Plumbapius.{ErrorFormat, ConnHelper}

  defstruct [:request, :status, :content_type, :body, :validation_error, :request_exception]

  defmodule RequestException do
    defstruct [:exc, :stack]

    @type t :: %__MODULE__{
            exc: Exception.t(),
            stack: Exception.stacktrace()
          }

    @spec new(Exception.t(), Exception.stacktrace()) :: t
    def new(exc, stack) do
      %__MODULE__{exc: exc, stack: stack}
    end

    defimpl String.Chars do
      def to_string(req_exc) do
        "\n\n" <> Exception.format(:error, req_exc.exc, req_exc.stack)
      end
    end
  end

  @type t :: %__MODULE__{
          request: %{method: String.t(), path: String.t()},
          status: non_neg_integer,
          content_type: String.t() | nil,
          body: iodata,
          validation_error: any,
          request_exception: any
        }

  @spec new(Plug.Conn.t(), any) :: t
  def new(conn, validation_error) do
    %__MODULE__{
      request: %{
        method: conn.method,
        path: conn.request_path
      },
      status: conn.status,
      content_type: ConnHelper.get_resp_header(conn, "content-type"),
      body: conn.resp_body,
      validation_error: validation_error,
      request_exception: request_exception(conn)
    }
  end

  defp request_exception(conn) do
    if is_exception(conn.assigns[:reason]) do
      RequestException.new(conn.assigns.reason, conn.assigns.stack)
    else
      nil
    end
  end

  defimpl String.Chars do
    def to_string(descr) do
      [
        ["Unexpected RESPONSE to ", descr.request.method |> String.upcase(), " ", descr.request.path],
        ["status: ", ErrorFormat.status(descr.status)],
        ["content-type: ", ErrorFormat.content_type(descr.content_type)],
        ["body: ", "`", ErrorFormat.body(descr.body), "`"],
        ["validation_error: ", ErrorFormat.schema_error(descr.validation_error)],
        descr.request_exception
      ]
      |> Enum.join("; ")
    end
  end
end
