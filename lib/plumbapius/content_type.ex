defmodule Plumbapius.ContentType do
  # исправить доку
  @moduledoc "Defines functions for the request content-type"

  @doc """
  Converts a request content-type from a schema to a regular expression.

  ## Parameters

    - request_content_type_schema: Request content-type for conversion.

  ## Examples
      iex> Plumbapius.ContentType.convert_for_schema(nil)
      :any_content_type

      iex> Plumbapius.ContentType.convert_for_schema("application/json")
      "application/json"

      iex> Plumbapius.ContentType.convert_for_schema("multipart/mixed; boundary={boundary}")
      ~r/\\Amultipart\\/mixed; boundary=[^\\s]+\\z/

  """

  @spec convert_for_schema(String.t() | nil) :: Regex.t() | String.t() | :any_content_type
  def convert_for_schema(nil), do: :any_content_type

  def convert_for_schema(content_type_schema) do
    variable_param_schema = ~r/\={\w+\}/
    variable_param_regex = "=[^\\s]+"

    path_with_regex =
      content_type_schema
      |> String.replace("\\\{", "{")
      |> String.replace("\\\}", "}")
      |> String.replace(variable_param_schema, variable_param_regex)

    if path_with_regex == content_type_schema do
      content_type_schema
    else
      ~r/\A#{path_with_regex}\z/
    end
  end

  @spec match?(String.t() | nil, Regex.t() | String.t() | :any_content_type) :: boolean()
  def match?(_content_type, :any_content_type = _schema_content_type), do: true

  def match?(nil = _content_type, _schema_content_type), do: false

  def match?(content_type, %Regex{} = schema_content_type) do
    String.match?(content_type, schema_content_type)
  end

  def match?(content_type, schema_content_type) when is_binary(schema_content_type) do
    content_type == schema_content_type ||
      (!has_directives?(schema_content_type) && strip_directives(content_type) == schema_content_type)
  end

  def has_directives?(content_type) do
    String.contains?(content_type, ";")
  end

  def strip_directives(content_type) do
    content_type |> String.split(";", limit: 2) |> hd()
  end
end
