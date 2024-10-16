defmodule TwimaWeb.ApiController do
  use TwimaWeb, :controller
  alias Twima.App
  alias Twima.Mastodon.Auth
  alias Twima.Memcache

  def register_app(conn, %{"url" => url}) do
    case Twima.Repo.get_by(App, url: url) do
      nil -> create_new_app(conn, url)
      creds -> redirect_to_auth_page(conn, creds)
    end
  end

  defp create_new_app(conn, url) do
    %{client_id: client_id, client_secret: client_secret} = Auth.post_app(url)

    creds =
      %App{
        client_id: client_id,
        client_secret: client_secret,
        url: url
      }
      |> App.changeset()
      |> Twima.Repo.insert!()

    redirect_to_auth_page(conn, creds)
  end

  def consume(conn, %{"code" => code, "state" => state}) do
    if get_session(conn, :state) == state do
      {:ok, creds} = Memcache.pop(state)
      %{"access_token" => token} = Auth.consume_code(creds, code)

      conn
      |> delete_session(:state)
      |> put_session(:token, token)
      |> put_session(:instance_url, creds.url)
      |> redirect(to: ~p"/choose")
    else
      conn
      |> put_flash(:error, "Invalid state parameter")
      |> delete_session(:state)
      |> redirect(to: ~p"/")
    end
  end

  defp redirect_to_auth_page(conn, creds) do
    {state, url} = Auth.auth_url(creds)
    :ok = Memcache.put(state, creds)

    conn
    |> put_session(:state, state)
    |> redirect(external: url)
  end

  def post_status(%{assigns: %{token: token, instance_url: instance_url}} = conn, params) do
    req = Twima.Mastodon.new(instance_url, token)
    %{"url" => url} = Twima.Mastodon.Fxtwi.post!(req, params)

    conn
    |> fetch_flash()
    |> put_flash(:info, "Posted! #{url}")
    |> redirect(to: ~p"/choose")
  end
end
