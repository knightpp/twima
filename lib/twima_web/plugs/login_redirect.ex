defmodule TwimaWeb.Plugs.LoginRedirect do
  def init(default), do: default

  def call(%{req_cookies: %{"token" => nil}, request_path: "/"} = conn, _default) do
    conn
  end

  def call(%{req_cookies: %{"token" => _}, request_path: "/"} = conn, _default) do
    conn
    |> Phoenix.Controller.redirect(to: "/choose")
    |> Plug.Conn.halt()
  end

  def call(%{req_cookies: %{"token" => nil}} = conn, _default) do
    conn
    |> Phoenix.Controller.redirect(to: "/")
    |> Plug.Conn.halt()
  end

  def call(conn, _default) do
    conn
  end
end
