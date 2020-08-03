defmodule Plumbapius.AbstractPlug do
  alias Plumbapius.{ContentType, Request, Response, ConnHelper}
  alias Plumbapius.Plug.Options
  alias Plumbapius.Coverage.CoverageTracker
  alias Plumbapius.Coverage.NullCoverageTracker

  @spec init(json_schema: String.t(), coverage_tracker: CoverageTracker.t()) :: Options.t()
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
    case find_request_schema(options.schema, conn) do
      {:ok, request_schema} ->
        validate_schema(request_schema, conn, handle_request_error, handle_response_error)

      {:error, _} = error ->
        handle_validation_result(error, handle_request_error, conn, Request.ErrorDescription)
    end
  end

  defp find_request_schema(request_schemas, conn) do
    case Enum.filter(request_schemas, &Request.match?(&1, conn.method, conn.request_path)) do
      [] ->
        {:error,
         %Request.NotFoundError{
           method: conn.method,
           path: conn.request_path
         }}

      [_ | _] = schema_candidates ->
        find_schema_by_content_type(conn, schema_candidates)
    end
  end

  defp find_schema_by_content_type(conn, schema_candidates) do
    with {:ok, content_type} <- content_type_for(conn) do
      request_schema = Enum.find(schema_candidates, &ContentType.match?(content_type, &1.content_type))

      if request_schema do
        {:ok, request_schema}
      else
        {:error,
         %Request.UnknownContentTypeError{
           method: conn.method,
           path: conn.request_path,
           content_type: content_type
         }}
      end
    end
  end

  defp validate_schema(request_schema, conn, handle_request_error, handle_response_error) do
    new_conn =
      Request.validate_body(request_schema, conn.body_params)
      |> handle_validation_result(handle_request_error, conn, Request.ErrorDescription)

    register_before_send = fn conn ->
      conn =
        parse_resp_body(conn.resp_body)
        |> validate_response(request_schema, conn.status, ConnHelper.get_resp_header(conn, "content-type"))
        |> handle_resp_validation_result(request_schema, handle_response_error, conn)

      conn
    end

    if new_conn.state == :sent do
      new_conn
    else
      Plug.Conn.register_before_send(new_conn, register_before_send)
    end
  end

  defp content_type_for(conn) do
    if has_body?(conn) do
      case ConnHelper.get_req_header(conn, "content-type") do
        nil -> {:error, %Request.NoContentTypeError{method: conn.method, path: conn.request_path}}
        content_type -> {:ok, content_type}
      end
    else
      {:ok, nil}
    end
  end

  defp has_body?(conn) do
    conn.method in ["POST", "PUT", "PATCH"]
  end

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

  defp handle_resp_validation_result(
         {:ok, %Response.Schema{} = response_schema},
         request_schema,
         _error_handler,
         conn
       ) do
    coverage_tracker().response_covered(request_schema, response_schema)
    conn
  end

  defp handle_resp_validation_result(
         {:error, _} = error,
         _request_schema,
         error_handler,
         conn
       ) do
    handle_validation_result(error, error_handler, conn, Response.ErrorDescription)
  end

  defp handle_validation_result(:ok, _error_handler, conn, _error_module) do
    conn
  end

  defp handle_validation_result({:error, error}, error_handler, conn, error_module) do
    error_module.new(conn, error)
    |> error_handler.(conn)
  end

  defp coverage_tracker do
    Application.get_env(:plumbapius, :coverage_tracker, NullCoverageTracker)
  end
end
