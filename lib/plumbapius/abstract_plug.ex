defmodule Plumbapius.AbstractPlug do
  alias Plumbapius.Request
  alias Plumbapius.Response
  alias Plumbapius.Plug.Options
  alias Plug.Conn

  @spec init(json_schema: String.t()) :: Options.t()
  def init(options) do
    Options.new(options)
  end

  @spec call(Plug.Conn.t(), Options.t(), function, function) ::
          Plug.Conn.t()
  def call(
        %{private: %{plumbapius_ignore: true}} = conn,
        _options,
        _handle_request_error,
        _handle_response_error
      ) do
    conn
  end

  def call(conn, options, handle_request_error, handle_response_error) do
    current_request_schema = find_request_schema(options.schema, conn)

    Request.validate(current_request_schema, conn.body_params)
    |> handle_validation_result(handle_request_error, conn, Request.ErrorDescription)

    register_before_send = fn conn ->
      parse_resp_body(conn.resp_body)
      |> validate_response(current_request_schema, conn.status, Map.get(conn, "content-type", nil))
      |> handle_validation_result(handle_response_error, conn, Response.ErrorDescription)

      conn
    end

    Plug.Conn.register_before_send(conn, register_before_send)
  end

  defp find_request_schema(request_schemas, conn) do
    schema_candidates = Enum.filter(request_schemas, &Request.match?(&1, conn.method, conn.request_path))

    if Enum.empty?(schema_candidates) do
      raise %Request.NotFoundError{
        method: conn.method,
        path: conn.request_path
      }
    end

    content_type = content_type_for(conn)
    request_schema = Enum.find(schema_candidates, &Request.match_content_type?(&1, content_type))

    unless request_schema do
      raise %Request.UnknownContentTypeError{
        method: conn.method,
        path: conn.request_path,
        content_type: content_type
      }
    end

    request_schema
  end

  defp content_type_for(conn) do
    if has_body?(conn) do
      content_type = get_req_header(conn, "content-type")

      unless content_type do
        raise %Request.NoContentTypeError{method: conn.method, path: conn.request_path}
      end

      content_type
    else
      nil
    end
  end

  defp has_body?(conn) do
    conn.method in ["POST", "PUT", "PATCH"]
  end

  defp get_req_header(conn, name), do: conn |> Conn.get_req_header(name) |> Enum.at(0)

  defp parse_resp_body(""), do: {:ok, %{}}
  defp parse_resp_body(body), do: Jason.decode(body)

  defp validate_response({:ok, resp_body}, request_schema, status, content_type) do
    Response.validate_response(
      request_schema,
      status,
      content_type,
      resp_body
    )
  end

  defp validate_response(error, _request_schema, _status, _content_type), do: error

  defp handle_validation_result(:ok, _error_handler, _conn, _validation_module), do: :ok

  defp handle_validation_result({:error, error}, error_handler, conn, error_module) do
    error_module.new(conn, error)
    |> error_handler.()
  end
end
