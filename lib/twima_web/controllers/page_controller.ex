defmodule TwimaWeb.PageController do
  use TwimaWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def choose(conn, %{"url" => url}) do
    post_data = Twima.Fxtwi.get!(Req.new(), url)
    render(conn, :compose, post_data)
  end

  def choose(conn, _params) do
    render(conn, :choose)
  end
end
