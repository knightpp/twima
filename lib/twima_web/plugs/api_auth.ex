defmodule TwimaWeb.Plugs.ApiAuth do
  def init(default), do: default

  def call(%{req_cookies: %{"token" => token}} = conn, _default) when is_binary(token) do
    conn
  end

  def call(conn, _default) do
    conn
    |> Plug.Conn.resp(401, "Not authorized")
    |> Plug.Conn.halt()
  end
end
