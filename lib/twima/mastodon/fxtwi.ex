defmodule Twima.Mastodon.Fxtwi do
  alias Twima.Mastodon

  @char_limit Application.compile_env!(:twima, :char_limit)

  # %{
  # "description" => "",
  # "image" => "",
  # "title" => "",
  # "url" => "",
  # "video" => "",
  # "video_mime" => ""
  # }
  def post!(req, %{"description" => status, "visibility" => visibility} = args) do
    media_id = upload_media!(req, args)
    wait_media_processing!(req, media_id)

    Mastodon.post_status!(
      req,
      status: limit_string(status, @char_limit),
      visibility: visibility,
      "media_ids[]": media_id
    )
  end

  defp upload_media!(_req, %{"video" => "", "image" => ""}), do: nil

  defp upload_media!(req, %{"video" => "", "image" => url}) do
    %{status: 200, body: image, headers: %{"content-type" => [mime]}} =
      Req.get!(url: url, redirect: false)

    %{"id" => id} = Mastodon.upload_media!(req, file: {image, content_type: mime, filename: url})

    id
  end

  defp upload_media!(req, %{"video" => video, "video_mime" => video_mime}) do
    %{status: 200, body: video_binary, headers: video_headers} =
      Req.get!(url: video, redirect: false)

    content_type = video_mime || getContentType(video_headers, "video/mp4")
    file = {video_binary, content_type: content_type, filename: video}

    %{"id" => id} = Mastodon.upload_media!(req, file: file)

    id
  end

  defp getContentType(headers, default) do
    case headers["content-type"] do
      [ct | _] -> ct
      _ -> default
    end
  end

  defp limit_string(str, max) when max > 1 do
    if String.length(str) <= max do
      str
    else
      str |> String.slice(0, max - 1) |> Kernel.<>("…")
    end
  end

  defp wait_media_processing!(_req, nil), do: :no_media

  defp wait_media_processing!(req, media_id) do
    case Mastodon.get_media!(req, media_id) do
      {:processing, _} ->
        :timer.sleep(:timer.seconds(1))
        wait_media_processing!(req, media_id)

      {:ok, _} ->
        :ok
    end
  end
end
