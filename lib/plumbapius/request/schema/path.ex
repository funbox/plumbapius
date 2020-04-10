defmodule Plumbapius.Request.Schema.Path do
  @moduledoc "Defines functions for the request path"

  @doc """
  Converts a request path from a schema to a regular expression.

  ## Parameters

    - request_path_schema: Request path for conversion.

  ## Examples

      iex> Plumbapius.Request.Schema.Path.to_regex("/users")
      ~r/\\A\\/users\\z/

      iex> Plumbapius.Request.Schema.Path.to_regex("/users/{id}/avatar")
      ~r/\\A\\/users\\/[^&=\\/]+\\/avatar\\z/

  """
  @spec to_regex(String.t()) :: Regex.t()
  def to_regex(request_path_schema) do
    resource_id_schema = ~r/\{\w+\}/
    resource_id_regex = "[^&=/]+"

    path_with_regex =
      request_path_schema
      |> Regex.escape()
      |> String.replace("\\\{", "{")
      |> String.replace("\\\}", "}")
      |> String.replace(resource_id_schema, resource_id_regex)

    ~r/\A#{path_with_regex}\z/
  end
end
