defmodule Twima.Mastodon.Auth do
  alias Twima.App

  @scopes "write:statuses write:media"
  @domain Application.compile_env!(:twima, :base_url)
  @redirect_uri "#{@domain}/api/consume"

  def post_app(url) when is_binary(url) do
    %{
      status: 200,
      body: %{
        "client_id" => client_id,
        "client_secret" => client_secret
      }
    } =
      Req.post!(
        base_url: url,
        url: "/api/v1/apps",
        form: [
          client_name: "twima helper",
          redirect_uris: @redirect_uri,
          scopes: @scopes,
          website: "https://mastodon.knightpp.cc/@knightpp"
        ]
      )

    %{client_id: client_id, client_secret: client_secret}
  end

  def auth_url(%App{} = creds) do
    state = :crypto.strong_rand_bytes(16) |> Base.encode64()

    url =
      creds.url
      |> URI.parse()
      |> URI.append_path("/oauth/authorize")
      |> URI.append_query(
        URI.encode_query(
          client_id: creds.client_id,
          scope: @scopes,
          redirect_uri: @redirect_uri,
          response_type: "code",
          state: state
        )
      )
      |> URI.to_string()

    {state, url}
  end

  def verify_credentials(url, access_token) when is_binary(url) and is_binary(access_token) do
    %{status: status} =
      Req.get!(
        base_url: url,
        url: "/api/v1/apps/verify_credentials",
        auth: {:bearer, access_token}
      )

    status == 200
  end

  def consume_code(%App{} = creds, code) do
    %{status: 200, body: body} =
      Req.post!(
        base_url: creds.url,
        url: "/oauth/token",
        form: [
          client_id: creds.client_id,
          client_secret: creds.client_secret,
          redirect_uri: @redirect_uri,
          grant_type: "authorization_code",
          code: code,
          scope: "write.statuses"
        ]
      )

    body
  end
end
