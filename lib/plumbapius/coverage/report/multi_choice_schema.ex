defmodule Plumbapius.Coverage.Report.MultiChoiceSchema do
  alias Plumbapius.Coverage.CoverageTracker

  @type multi_choice :: {path :: list(String.t()), schema :: map()}
  @type t :: list(multi_choice)

  @spec multi_choices(list(CoverageTracker.interaction())) :: %{
          optional(CoverageTracker.interaction()) => list(multi_choice())
        }
  def multi_choices(interactions) do
    interactions
    |> Enum.map(fn {req, resp} = interaction ->
      {interaction, Enum.flat_map(req.bodies, &new(&1.schema)) ++ new(resp.body.schema)}
    end)
    |> Enum.into(%{})
  end

  @spec new(map) :: t
  def new(schema) do
    walk_properties([], schema)
  end

  defp walk_properties(current_path, %{"properties" => properties}) do
    Enum.flat_map(properties, fn {key, value} ->
      property_choices(current_path ++ [key], value)
    end)
  end

  defp walk_properties(_current_path, _schema) do
    []
  end

  defp property_choices(current_path, %{"type" => "object", "oneOf" => choices}) do
    Enum.flat_map(choices, fn choice ->
      schema_fragment = Map.put(choice, "type", "object")
      [{current_path, schema_fragment} | walk_properties(current_path, choice)]
    end)
  end

  defp property_choices(current_path, %{"type" => "string", "enum" => choices}) when length(choices) > 1 do
    Enum.map(choices, fn choice ->
      schema_fragment = %{"type" => "string", "enum" => [choice]}
      {current_path, schema_fragment}
    end)
  end

  defp property_choices(current_path, %{"type" => "object"} = schema) do
    walk_properties(current_path, schema)
  end

  defp property_choices(_current_path, _value) do
    []
  end
end
