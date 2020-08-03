defmodule Plumbapius.Response do
  @moduledoc "Defines methods for validating responses by request schema"

  alias __MODULE__
  alias Plumbapius.{ContentType, Request}

  @spec validate_response(
          request_schema :: Request.Schema.t(),
          response_status :: non_neg_integer,
          response_content_type :: String.t(),
          body :: map
        ) :: {:ok, Response.Schema.t()} | {:error, String.t()}
  def validate_response(request_schema, response_status, response_content_type, response_body) do
    request_schema.responses
    |> find_tomogram(response_status, response_content_type)
    |> validate_body(response_body)
  end

  defp find_tomogram(responses, response_status, response_content_type) do
    responses
    |> Enum.filter(&match?(&1, response_status, response_content_type))
  end

  defp match?(response_schema, response_status, response_content_type) do
    response_schema.status == response_status &&
      ContentType.match?(response_content_type, response_schema.content_type)
  end

  defp validate_body([response_schema | rest], response_body) do
    case ExJsonSchema.Validator.validate(response_schema.body, response_body) do
      :ok ->
        {:ok, response_schema}

      _ ->
        validate_body(rest, response_body)
    end
  end

  defp validate_body([], _response_body) do
    {:error, "no_such_response_in_schema"}
  end
end
