defmodule Plumbapius.Request.Schema do
  @moduledoc "Describes the request schema for validation"

  @enforce_keys [:method, :path, :content_type, :body]
  defstruct [:method, :path, :content_type, :body, responses: []]

  @typedoc "Request Schema"
  @type t :: %__MODULE__{
          method: String.t(),
          path: Regex.t(),
          content_type: String.t(),
          body: ExJsonSchema.Schema.Root.t(),
          responses: [Plumbapius.Response.Schema.t()]
        }

  @doc """
  Returns a request scheme created from a tomogram.

  ## Parameters

    - tomogram: Description of the request scheme as a hash.

  ## Examples

      iex> Plumbapius.Request.Schema.new(%{
      ...>   "method"=>"GET",
      ...>   "path"=>"/users/{id}",
      ...>   "content-type"=>"application/json",
      ...>   "request"=>%{
      ...>     "$schema" => "http://json-schema.org/draft-04/schema#",
      ...>     "type" => "object",
      ...>     "properties" => %{"msisdn" => %{"type" => "number"}},
      ...>     "required" => ["msisdn"]
      ...>   },
      ...>   "responses"=>[]
      ...> })
      %Plumbapius.Request.Schema{
        method: "GET",
        path: ~r/\\A\\/users\\/[^&=\\/]+\\z/,
        content_type: "application/json",
        body: %ExJsonSchema.Schema.Root{
          custom_format_validator: nil,
          location: :root,
          refs: %{},
          schema: %{
            "$schema" => "http://json-schema.org/draft-04/schema#",
            "type" => "object",
            "properties" => %{"msisdn" => %{"type" => "number"}},
            "required" => ["msisdn"]
          }
        },
        responses: []
      }

  """
  @spec new(map()) :: t()
  def new(tomogram) when is_map(tomogram) do
    %__MODULE__{
      method: Map.fetch!(tomogram, "method"),
      path: Map.fetch!(tomogram, "path") |> Plumbapius.Request.Schema.Path.to_regex(),
      content_type: Map.fetch!(tomogram, "content-type"),
      body: Map.fetch!(tomogram, "request") |> ExJsonSchema.Schema.resolve(),
      responses: Map.fetch!(tomogram, "responses") |> Enum.map(&Plumbapius.Response.Schema.new/1)
    }
  end
end
