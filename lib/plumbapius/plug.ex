defmodule Plumbapius.Plug do
  alias Plumbapius.Request
  alias Plumbapius.Response
  alias Plumbapius.Plug.Options

  @spec init(apib_json_filepath: String.t()) :: Options.t()
  def init(options) do
    Options.new(options)
  end

  @spec call(Plug.Conn.t(), Options.t(), function, function) ::
          Plug.Conn.t()
  def call(conn, options, handle_request_error, handle_response_error) do
    content_type = Plug.Conn.get_req_header(conn, "content-type") |> Enum.at(0)

    current_request_schema =
      options.schema
      |> find_request(conn.method, conn.request_path, content_type)

    Request.validate_request(current_request_schema, conn.body_params)
    |> handle_validation_result(handle_request_error, conn, Request.ErrorDescription)

    register_before_send = fn conn ->
      validate_response(current_request_schema, conn.resp_body, conn.status)
      |> handle_validation_result(handle_response_error, conn, Response.ErrorDescription)

      conn
    end

    Plug.Conn.register_before_send(conn, register_before_send)
  end

  defp find_request(request_schemas, request_method, request_path, request_content_type) do
    case Enum.find(
           request_schemas,
           &Request.match?(&1, request_method, request_path, request_content_type)
         ) do
      nil ->
        raise %Request.NotFoundError{
          method: request_method,
          path: request_path,
          content_type: request_content_type
        }

      request_schema ->
        request_schema
    end
  end

  defp validate_response(request_schema, resp_body, status) do
    case parse_resp_body(resp_body) do
      {:ok, resp_body} ->
        Response.validate_response(
          request_schema,
          status,
          resp_body
        )

      error ->
        error
    end
  end

  defp parse_resp_body(""), do: {:ok, %{}}

  defp parse_resp_body(body), do: Poison.decode(body)

  defp handle_validation_result(:ok, _error_handler, _conn, _validation_module), do: :ok

  defp handle_validation_result({:error, error}, error_handler, conn, error_module) do
    error_module.new(conn, error)
    |> error_handler.()
  end
end
