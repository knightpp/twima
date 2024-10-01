defmodule TwimaWeb.PageController do
  use TwimaWeb, :controller

  plug TwimaWeb.Plugs.LoginRedirect

  def home(conn, _params) do
    render(conn, :home)
  end

  def choose(conn, _params) do
    render(conn, :choose)
  end

  def compose(conn, _params) do
    render(conn, :compose)
  end

  def post_status(conn, params) do
    compose(conn, params)
  end
end
