defmodule TwimaWeb.PageController do
  use TwimaWeb, :controller

  plug TwimaWeb.Plugs.LoginRedirect

  def home(conn, _params) do
    render(conn, :home)
  end

  def choose(conn, %{"url" => _} = params) do
    post_choose(conn, params)
  end

  def choose(conn, _params) do
    render(conn, :choose)
  end

  def post_choose(conn, %{"url" => url}) do
    post_data = Twima.Fxtwi.get!(Req.new(), url)

    render(conn, :compose, post_data)
  end
end
