defmodule Plumbapius.Request.Schema do
  @moduledoc "Describes the request schema for validation"

  alias Plumbapius.ContentType
  alias Plumbapius.Request.Schema.Path
  alias Plumbapius.Response.Schema, as: ResponseSchema

  @enforce_keys [:method, :path]
  defstruct [:method, :original_path, :path, :content_type, :body, responses: []]

  @typedoc "Request Schema"
  @type t :: %__MODULE__{
          method: String.t(),
          original_path: String.t(),
          path: Regex.t(),
          content_type: Regex.t() | String.t() | :any_content_type,
          body: ExJsonSchema.Schema.Root.t(),
          responses: [ResponseSchema.t()]
        }

  @doc """
  Returns a request schema created from a tomogram.

  ## Parameters

    - tomogram: Description of the request schema as a hash.

  ## Examples

      iex> Plumbapius.Request.Schema.new(%{
      ...>   "method"=>"GET",
      ...>   "path"=>"/users/{id}",
      ...>   "content-type"=>"multipart/mixed; boundary={boundary}",
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
        original_path: "/users/{id}",
        path: ~r/\\A\\/users\\/[^&=\\/]+\\z/,
        content_type: ~r/\\Amultipart\\/mixed; boundary=[^\\s]+\\z/,
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
      original_path: Map.fetch!(tomogram, "path"),
      path: Map.fetch!(tomogram, "path") |> Path.to_regex(),
      content_type: Map.fetch!(tomogram, "content-type") |> ContentType.convert_for_schema(),
      body: Map.fetch!(tomogram, "request") |> ExJsonSchema.Schema.resolve(),
      responses: Map.fetch!(tomogram, "responses") |> Enum.map(&ResponseSchema.new/1)
    }
  end
end
