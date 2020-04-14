defmodule Plumbapius.Request.ErrorDescription do
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
end
