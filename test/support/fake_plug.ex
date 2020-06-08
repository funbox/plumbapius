defmodule FakePlug do
  alias Plumbapius.Request
  alias Plumbapius.Response

  @spec call(:request_error | :response_error | :both | nil, any, function, function) :: any

  def call(nil, _opts, _handle_request_error, _handle_resposne_error), do: {:ok, :called}

  def call(:request_error, _opts, handle_request_error, _handle_response_error) do
    handle_request_error.(request_error())
  end

  def call(:response_error, _opts, _handle_request_error, handle_response_error) do
    handle_response_error.(response_error())
  end

  def call(:both, _opts, handle_request_error, handle_response_error) do
    handle_request_error.(request_error())
    handle_response_error.(response_error())
  end

  defp request_error,
    do: %Request.ErrorDescription{
      method: "get",
      path: "/fake/path",
      body: %{"foo" => "bar"},
      error: "some_error"
    }

  defp response_error,
    do: %Response.ErrorDescription{
      request: %{
        method: "get",
        path: "/fake/path"
      },
      status: 200,
      content_type: "application/json",
      body: ["{", "foo", ":", "bar", "}"],
      error: "invalid"
    }
end
