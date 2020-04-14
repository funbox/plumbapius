defmodule Plumbapius.Request do
  @moduledoc "Defines methods for validating requests by scheme"

  defmodule NotFoundError do
    @moduledoc "Describes a request search error in api schema"
    defexception [:method, :path, :content_type]

    @impl true
    def message(exception) do
      "request #{inspect(exception.method)}: #{inspect(exception.path)} with content-type: #{
        inspect(exception.content_type)
      } not found"
    end
  end

  alias Plumbapius.Request

  @doc """
  Validates the request body according to the scheme.

  ## Parameters

    - request_schema: Request schema for validation.
    - request_body: Request body to validate.

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
      ...>   "responses"=>[]
      ...> })
      iex> Plumbapius.Request.validate_request(request_schema, %{"msisdn" => 12345})
      :ok
      iex> Plumbapius.Request.validate_request(request_schema, %{"msisdn" => "12345"})
      {:error, [{"Type mismatch. Expected Number but got String.", "#/msisdn"}]}

  """
  @spec validate_request(Request.Schema.t(), map()) :: :ok | {:error, list()}
  def validate_request(request_schema, request_body) do
    ExJsonSchema.Validator.validate(request_schema.body, request_body)
  end

  @doc """
  Compares the schema with the request.

  ## Parameters

    - request_schema: Request schema for comparison.
    - request_method: Request method to compare.
    - request_path: Request path to compare.

  ## Examples

      iex> request_schema = Plumbapius.Request.Schema.new(%{
      ...>   "method"=>"GET",
      ...>   "path"=>"/users/{id}",
      ...>   "content-type"=>"application/json",
      ...>   "request"=>%{},
      ...>   "responses"=>[]
      ...> })
      iex> Plumbapius.Request.match?(request_schema, "GET", "/users/1", "application/json")
      true
      iex> Plumbapius.Request.match?(request_schema, "GET", "/users", "application/json")
      false
      iex> Plumbapius.Request.match?(request_schema, "POST", "/users/1", "application/json")
      false
      iex> Plumbapius.Request.match?(request_schema, "GET", "/users/1", "plain/text")
      false
  """
  @spec match?(Request.Schema.t(), String.t(), String.t(), String.t()) :: boolean()
  def match?(request_schema, request_method, request_path, request_content_type) do
    String.equivalent?(request_method, request_schema.method) &&
      String.equivalent?(request_content_type, request_schema.content_type) &&
      String.match?(request_path, request_schema.path)
  end
end
