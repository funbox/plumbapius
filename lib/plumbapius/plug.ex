defmodule Plumbapius.Plug do
  alias Plumbapius.Request
  alias Plumbapius.Response

  defmodule IncorrectSchemaError do
    defexception message: "Incorrect json schema"
  end

  @spec init(apib_json_filepath: String.t()) :: [schema: list(Request.Schema.t())]
  def init(options) do
    schema =
      Keyword.fetch!(options, :apib_json_filepath)
      |> parse_apib_json
      |> create_schema

    options
    |> Keyword.put(:schema, schema)
    |> Keyword.delete(:apib_json_filepath)
  end

  @spec call(Plug.Conn.t(), [schema: list(Request.Schema.t())], function, function) ::
          Plug.Conn.t()
  def call(conn, options, handle_request_error, handle_response_error) do
    request_schema =
      Keyword.get(options, :schema)
      |> find_request(conn.method, conn.request_path)

    if request_schema == %Request.NotFoundError{}, do: raise(request_schema)

    Request.validate_request(request_schema, conn.body_params)
    |> handle_validation_result(handle_request_error, conn)

    Plug.Conn.register_before_send(conn, fn conn ->
      Response.validate_response(request_schema, conn.status, conn.resp_body)
      |> handle_validation_result(handle_response_error, conn)

      conn
    end)
  end

  defp parse_apib_json(file_path) do
    with {:ok, body} <- File.read(file_path),
         {:ok, schema} <- Poison.decode(body) do
      schema
    else
      error ->
        raise IncorrectSchemaError, message: "#{inspect(error)}"
    end
  end

  defp create_schema(tomogram) when is_list(tomogram) do
    tomogram
    |> Enum.map(&Request.Schema.new/1)
  end

  defp find_request(request_schemas, request_method, request_path) do
    match_method = fn request_schema ->
      Request.match?(request_schema, request_method, request_path)
    end

    Enum.find(request_schemas, match_method) || Request.NotFoundError
  end

  defp handle_validation_result(:ok, _error_handler, _conn), do: :ok

  defp handle_validation_result({:error, error}, error_handler, conn) do
    error_handler.(conn, error)
  end
end
