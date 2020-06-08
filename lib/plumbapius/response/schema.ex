defmodule Plumbapius.Response.Schema do
  @moduledoc "Describes the response schema for validation"

  alias Plumbapius.ContentType

  @enforce_keys [:status, :content_type, :body]
  defstruct [:status, :content_type, :body]

  @typedoc "Response Schema"
  @type t :: %__MODULE__{
          status: non_neg_integer,
          content_type: Regex.t() | String.t() | :any_content_type,
          body: ExJsonSchema.Schema.Root.t()
        }

  @doc """
  Returns a response schema created from a tomogram.

  ## Parameters

    - tomogram: Description of the response schema as a hash.

  ## Examples

      iex> Plumbapius.Response.Schema.new(%{
      ...>   "status" => "200",
      ...>   "content-type" => "application/json",
      ...>   "body" => %{
      ...>     "$schema" => "http://json-schema.org/draft-04/schema#",
      ...>     "type" => "object",
      ...>     "properties" => %{"msisdn" => %{"type" => "number"}},
      ...>     "required" => ["msisdn"]
      ...>   }
      ...> })
      %Plumbapius.Response.Schema{
        status: 200,
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
        }
      }

  """
  @spec new(map()) :: t()
  def new(tomogram) when is_map(tomogram) do
    %__MODULE__{
      status: Map.fetch!(tomogram, "status") |> String.to_integer(),
      content_type: Map.fetch!(tomogram, "content-type") |> ContentType.convert_for_schema(),
      body: Map.fetch!(tomogram, "body") |> ExJsonSchema.Schema.resolve()
    }
  end
end
