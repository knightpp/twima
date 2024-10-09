defmodule Twima.Mastodon do
  def new(url, access_token) do
    Req.new(base_url: url, auth: {:bearer, access_token})
    |> Req.Request.put_header("user-agent", "twima")
  end

  def verify_credentials!(req) do
    %{status: 200, body: body} = Req.get!(req, url: "api/v1/apps/verify_credentials")
    body
  end

  def upload_media(req, data) do
    with {:ok, %{status: status, body: body}} =
           Req.post(req, url: "/api/v2/media", form_multipart: data) do
      case status do
        200 ->
          {:ok, body}

        202 ->
          {:ok, body}

        status ->
          {
            :error,
            # TODO: didn't work
            # %Embot.Mastodon.Error{
            %{
              message: "unexpected status code",
              body: body,
              status: status
            }
          }
      end
    end
  end

  def upload_media!(req, data) do
    case Req.post!(req, url: "/api/v2/media", form_multipart: data) do
      %{status: 200, body: body} -> body
      %{status: 202, body: body} -> body
    end
  end

  def post_status!(req, form_data) do
    %{status: 200, body: body} =
      Req.post!(req,
        url: "/api/v1/statuses",
        form: form_data
      )

    body
  end

  def get_media!(req, id) do
    %{status: status, body: body} =
      Req.get!(req,
        url: "/api/v1/media/:id",
        path_params: [id: id]
      )

    case status do
      206 ->
        {:processing, body}

      200 ->
        {:ok, body}
    end
  end
end

defmodule Embot.Mastodon.Error do
  defexception [:message, :body, :status]

  @impl true
  def message(%{message: msg, body: body, status: status}) do
    """
      Msg: #{msg}
      Status: #{status}
      Body: #{body}
    """
  end
end
