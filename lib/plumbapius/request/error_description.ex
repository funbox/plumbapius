defmodule Plumbapius.Request.ErrorDescription do
  # credo:disable-for-this-file Credo.Check.Readability.Specs
  alias Plumbapius.ErrorFormat

  defstruct [:method, :path, :body, :error]

  @type t :: %__MODULE__{
          method: String.t(),
          path: String.t(),
          body: %{optional(binary()) => term()},
          error: any
        }

  @spec new(Plug.Conn.t(), any) :: t
  def new(conn, error) do
    %__MODULE__{
      method: conn.method,
      path: conn.request_path,
      body: conn.body_params,
      error: error
    }
  end

  defimpl String.Chars do
    def to_string(descr) do
      "Unexpected REQUEST to #{descr.method |> String.upcase()} #{descr.path}; " <>
        "body: `#{ErrorFormat.body(descr.body)}`; error: #{ErrorFormat.schema_error(descr.error)}"
    end
  end
end
