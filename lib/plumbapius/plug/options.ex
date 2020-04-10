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

  @spec new(apib_json_filepath: String.t()) :: t()
  def new(options) do
    %__MODULE__{
      schema:
        Keyword.fetch!(options, :apib_json_filepath)
        |> parse_apib_json
        |> create_schema
    }
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
end
