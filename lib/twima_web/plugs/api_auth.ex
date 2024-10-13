defmodule TwimaWeb.Plugs.ApiAuth do
  def init(default), do: default

  def call(conn, _default) do
    token = Plug.Conn.get_session(conn, :token)
    url = Plug.Conn.get_session(conn, :instance_url)

    authorized =
      token != nil and
        url != nil

    if authorized do
      conn
      |> Plug.Conn.assign(:token, token)
      |> Plug.Conn.assign(:instance_url, url)
    else
      conn
      |> Plug.Conn.resp(401, "Not authorized")
      |> Plug.Conn.halt()
    end
  end
end
