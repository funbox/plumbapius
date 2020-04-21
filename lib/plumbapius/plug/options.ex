defmodule Plumbapius.Plug.Options do
  defstruct [:schema]

  alias Plumbapius.Request

  defmodule IncorrectSchemaError do
    defexception message: "Incorrect json schema"
  end

  @typedoc "Plug Options"
  @type t :: %__MODULE__{
          schema: list(Request.Schema.t())
        }

  @spec new(json_schema: String.t()) :: t()
  def new(options) do
    %__MODULE__{
      schema:
        Keyword.fetch!(options, :json_schema)
        |> parse_apib_json
        |> create_schema
    }
  end

  defp parse_apib_json(body) do
    case Jason.decode(body) do
      {:ok, schema} ->
        schema

      error ->
        raise IncorrectSchemaError, message: "#{inspect(error)}"
    end
  end

  defp create_schema(tomogram) when is_list(tomogram) do
    tomogram
    |> Enum.map(&Request.Schema.new/1)
  end
end
