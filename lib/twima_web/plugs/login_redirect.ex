defmodule TwimaWeb.Plugs.LoginRedirect do
  def init(default), do: default

  def call(%{request_path: "/"} = conn, _default) do
    case Plug.Conn.get_session(conn, :token) do
      nil ->
        conn

      _ ->
        conn
        |> Phoenix.Controller.redirect(to: "/choose")
        |> Plug.Conn.halt()
    end
  end

  def call(conn, _default) do
    case Plug.Conn.get_session(conn, :token) do
      nil ->
        conn
        |> Phoenix.Controller.redirect(to: "/")
        |> Plug.Conn.halt()

      _ ->
        conn
    end
  end
end
