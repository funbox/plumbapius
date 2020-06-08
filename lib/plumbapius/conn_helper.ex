defmodule Plumbapius.ConnHelper do
  alias Plug.Conn

  @spec get_req_header(Conn.t(), String.t()) :: binary | nil
  def get_req_header(conn, name), do: conn |> Conn.get_req_header(name) |> Enum.at(0)

  @spec get_resp_header(Conn.t(), String.t()) :: binary | nil
  def get_resp_header(conn, name), do: conn |> Conn.get_resp_header(name) |> Enum.at(0)
end
