defmodule TwimaWeb.Plugs.ApiAuth do
  def init(default), do: default

  def call(%{req_cookies: %{"token" => token, "instance_url" => instance_url}} = conn, _default)
      when is_binary(token) and is_binary(instance_url) do
    conn
    |> Plug.Conn.assign(:token, token)
    |> Plug.Conn.assign(:instance_url, instance_url)
  end

  def call(conn, _default) do
    conn
    |> Plug.Conn.resp(401, "Not authorized")
    |> Plug.Conn.halt()
  end
end
