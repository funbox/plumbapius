defmodule Plumbapius do
  @spec ignore(Plug.Conn.t()) :: Plug.Conn.t()
  def ignore(conn), do: Plug.Conn.put_private(conn, :plumbapius_ignore, true)
end
