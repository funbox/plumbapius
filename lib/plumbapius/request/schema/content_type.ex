defmodule Plumbapius.Request.Schema.ContentType do
  # исправить доку
  @moduledoc "Defines functions for the request content-type"

  @doc """
  Converts a request content-type from a schema to a regular expression.

  ## Parameters

    - request_content_type_schema: Request content-type for conversion.

  ## Examples

      iex> Plumbapius.Request.Schema.ContentType.to_regex("application/json")
      ~r/\\Aapplication\\/json\\z/

      iex> Plumbapius.Request.Schema.ContentType.to_regex("multipart/mixed; boundary={boundary}")
      ~r/\\Amultipart\\/mixed;\\ boundary=[^\\s]+\\z/

  """

  @spec to_regex(String.t()) :: Regex.t()
  def to_regex(nil) do
    ~r/\Anull\z/
  end

  def to_regex(request_content_type_schema) do
    variable_param_schema = ~r/\={\w+\}/
    variable_param_regex = "=[^\\s]+"

    path_with_regex =
      request_content_type_schema
      |> Regex.escape()
      |> String.replace("\\\{", "{")
      |> String.replace("\\\}", "}")
      |> String.replace(variable_param_schema, variable_param_regex)

    ~r/\A#{path_with_regex}\z/
  end
end
