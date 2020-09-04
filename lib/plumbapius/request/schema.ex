defmodule Plumbapius.Request.Schema do
  @moduledoc "Describes the request schema for validation"

  alias Plumbapius.ContentType
  alias Plumbapius.Request.Schema.Path
  alias Plumbapius.Response.Schema, as: ResponseSchema

  defmodule NotFoundReqestsParametersError do
    defexception [:tomogram]

    @impl true
    def message(exception) do
      "Not found 'reqest' or 'reqests' parameters in tomogram schema: #{inspect(exception.tomogram)}"
    end
  end

  @enforce_keys [:method, :path]
  defstruct [:method, :original_path, :path, :content_type, bodies: [], responses: []]

  @typedoc "Request Schema"
  @type t :: %__MODULE__{
          method: String.t(),
          original_path: String.t(),
          path: Regex.t(),
          content_type: Regex.t() | String.t() | :any_content_type,
          bodies: [ExJsonSchema.Schema.Root.t()],
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
        bodies: [
          %ExJsonSchema.Schema.Root{
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
        ],
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
      bodies: fetch_requests!(tomogram) |> Enum.map(&ExJsonSchema.Schema.resolve/1),
      responses: Map.fetch!(tomogram, "responses") |> Enum.map(&ResponseSchema.new/1)
    }
  end

  defp fetch_requests!(%{"request" => request}) when is_map(request), do: [request]
  defp fetch_requests!(%{"requests" => requests}) when is_list(requests), do: requests
  defp fetch_requests!(tomogram), do: raise(%NotFoundReqestsParametersError{tomogram: tomogram})
end
