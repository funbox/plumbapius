defmodule Plumbapius.Request do
  @moduledoc "Defines methods for validating requests by scheme"

  defmodule NotFoundError do
    defexception [:method, :path]

    @impl true
    def message(exception) do
      "request #{exception.method}: #{exception.path}"
    end
  end

  defmodule UnknownContentTypeError do
    defexception [:method, :path, :content_type]

    @impl true
    def message(exception) do
      "request #{exception.method}: #{exception.path} " <>
        "with content-type: #{exception.content_type} not found. " <>
        "Make sure you have correct `content-type` or `accept` headers in your request"
    end
  end

  defmodule NoContentTypeError do
    defexception [:method, :path]

    @impl true
    def message(exception) do
      "request #{exception.method}: #{exception.path} has no content-type header"
    end
  end

  alias Plumbapius.Request

  @doc """
  Validates request body according to a scheme.

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
      iex> Plumbapius.Request.validate(request_schema, %{"msisdn" => 12345})
      :ok
      iex> Plumbapius.Request.validate(request_schema, %{"msisdn" => "12345"})
      {:error, [{"Type mismatch. Expected Number but got String.", "#/msisdn"}]}

  """
  @spec validate(Request.Schema.t(), map()) :: :ok | {:error, list()}
  def validate(request_schema, request_body) do
    ExJsonSchema.Validator.validate(request_schema.body, request_body)
  end

  @spec match?(Request.Schema.t(), String.t(), String.t()) :: boolean()
  def match?(_schema, _request_method, nil), do: false

  def match?(schema, request_method, request_path) do
    String.match?(request_path, schema.path) && schema.method == request_method
  end

  @spec match_content_type?(Request.Schema.t(), String.t() | nil) :: boolean()
  def match_content_type?(_schema, nil = _request_content_type), do: true

  def match_content_type?(schema, request_content_type) do
    schema.content_type == request_content_type
  end
end
