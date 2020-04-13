defmodule FakePlug do
  @spec call(atom | nil, any, function, function) :: any
  def call(:request_error, _opts, handle_request_error, _handle_response_error) do
    handle_request_error.(request_error())
  end

  def call(:response_error, _opts, _handle_request_error, handle_response_error) do
    handle_response_error.(response_error())
  end

  def call(_conn, _opts, handle_request_error, handle_response_error) do
    handle_request_error.(request_error())
    handle_response_error.(response_error())
  end

  defp request_error,
    do: %{
      method: "get",
      path: "/fake/path",
      body: %{"foo" => "bar"},
      error: [{"Type mismatch. Expected Number but got String.", "#/msisdn"}]
    }

  defp response_error,
    do: %{
      request: %{
        method: "get",
        path: "/fake/path"
      },
      status: 200,
      body: %{"bar" => "foo"},
      error: "invalid"
    }
end
