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
      iex> Plumbapius.Response.validate_response(request_schema, 200, %{"field_name" => "foobar"})
      :ok
      iex> Plumbapius.Response.validate_response(request_schema, 200, %{"another_field_name" => "12345"})
      {:error, "no_such_response_in_schema"}
      iex> Plumbapius.Response.validate_response(request_schema, 401, %{"field_name" => "foobar"})
      {:error, "no_such_response_in_schema"}

  """
  @spec validate_response(Request.Schema.t(), non_neg_integer, map) :: :ok | {:error, String.t()}
  def validate_response(request_schema, response_status, response_body) do
    response_status
    |> find_tomogram(request_schema.responses)
    |> validate(response_body)
  end

  defp find_tomogram(response_status, responses) do
    responses
    |> Enum.filter(&(&1.status == response_status))
  end

  defp validate([response_schema | rest], response_body) do
    case ExJsonSchema.Validator.validate(response_schema.body, response_body) do
      :ok ->
        :ok

      _ ->
        validate(rest, response_body)
    end
  end

  defp validate([], _response_body) do
    {:error, "no_such_response_in_schema"}
  end
end
