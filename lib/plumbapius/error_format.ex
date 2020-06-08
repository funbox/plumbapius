defmodule Plumbapius.ErrorFormat do
  @moduledoc false

  @spec status(non_neg_integer) :: binary
  def status(status), do: to_string(status)

  @spec content_type(String.t() | nil) :: binary
  def content_type(status), do: status || "empty"

  @spec body(any) :: binary
  def body(body) do
    to_s(body)
  end

  @spec schema_error(any) :: binary
  def schema_error(error) do
    to_s(error)
  end

  defp to_s(term) when is_list(term) do
    IO.iodata_to_binary(term)
  rescue
    ArgumentError ->
      Enum.map_join(term, ", ", &to_s/1)
  end

  defp to_s(term) do
    if String.Chars.impl_for(term) do
      to_string(term)
    else
      inspect(term)
    end
  end
end
