defmodule Plumbapius.Response do
  @moduledoc "Defines methods for validating responses by request scheme"

  alias Plumbapius.Request

  @doc """
  Validates the response body according to the scheme.

  ## Parameters

    - request_schema: Request schema with responses for validation.
    - response_status: Response status.
    - response_body: Response body to validate.

  ## Examples

      iex> request_schema = Plumbapius.Request.Schema.new(%{
      ...>   "method"=>"GET",
      ...>   "path"=>"/users",
      ...>   "content-type"=>"application/json",
      ...>   "request"=>%{
      ...>     "$schema" => "http://json-schema.org/draft-04/schema#",
      ...>     "type" => "object",
      ...>     "properties" => %{"msisdn" => %{"type" => "number"}},
      ...>     "required" => ["msisdn"]
      ...>   },
      ...>   "responses"=>[
      ...>     %{
      ...>       "content-type" => "application/json",
      ...>       "status" => "200",
      ...>       "body" => %{
      ...>         "$schema" => "http://json-schema.org/draft-04/schema#",
      ...>         "type"=> "object",
      ...>         "properties" => %{
      ...>           "field_name" => %{"type" => "string"}
      ...>         },
      ...>         "required" => ["field_name"],
      ...>       }
      ...>     }
      ...>   ]
      ...> })
      iex> Plumbapius.Response.validate_response(request_schema, 200, "application/json", %{"field_name" => "foobar"})
      :ok
      iex> Plumbapius.Response.validate_response(request_schema, 200, "application/json", %{"another_field_name" => "12345"})
      {:error, "no_such_response_in_schema"}
      iex> Plumbapius.Response.validate_response(request_schema, 200, "text/plain", %{"field_name" => "foobar"})
      {:error, "no_such_response_in_schema"}
      iex> Plumbapius.Response.validate_response(request_schema, 401, "application/json", %{"field_name" => "foobar"})
      {:error, "no_such_response_in_schema"}

  """
  @spec validate_response(
          request_schema :: Request.Schema.t(),
          response_status :: non_neg_integer,
          response_content_type :: String.t(),
          body :: map
        ) :: :ok | {:error, String.t()}
  def validate_response(request_schema, response_status, response_content_type, response_body) do
    request_schema.responses
    |> find_tomogram(response_status, response_content_type)
    |> validate_response_body(response_body)
  end

  defp find_tomogram(responses, response_status, response_content_type) do
    responses
    |> Enum.filter(&match?(&1, response_status, response_content_type))
  end

  defp match?(response_schema, response_status, response_content_type) do
    response_schema.status == response_status &&
      match_content_type?(response_schema.content_type, response_content_type)
  end

  defp match_content_type?(_schema_content_type, nil = _response_content_type), do: true

  defp match_content_type?(schema_content_type, response_content_type) do
    schema_content_type == response_content_type
  end

  defp validate_response_body([response_schema | rest], response_body) do
    case ExJsonSchema.Validator.validate(response_schema.body, response_body) do
      :ok ->
        :ok

      _ ->
        validate_response_body(rest, response_body)
    end
  end

  defp validate_response_body([], _response_body) do
    {:error, "no_such_response_in_schema"}
  end
end
