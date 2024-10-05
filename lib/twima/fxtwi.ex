defmodule Twima.Fxtwi do
  @type t() :: %{
          title: String.t(),
          description: String.t(),
          url: String.t(),
          video: nil | String.t(),
          image: nil | String.t(),
          video_mime: nil | String.t()
        }

  def patch_url!(link) do
    case patch_url(link) do
      {:ok, patched} -> patched
      {:error, term} -> raise term
    end
  end

  def patch_url(link) do
    uri = URI.parse(link)

    case uri.host do
      "x.com" -> {:ok, %URI{uri | host: "fixupx.com"} |> URI.to_string()}
      "twitter.com" -> {:ok, %URI{uri | host: "fxtwitter.com"} |> URI.to_string()}
      host -> {:error, "unknown host=#{host} of link=#{link}"}
    end
  end

  @spec get(Req.Request.t(), String.t()) :: {:ok, Twima.Fxtwi.t()} | {:error, term()}
  def get(req, url) do
    with {:ok, url} <- patch_url(url),
         {:ok, %Req.Response{status: 200, body: body}} <-
           Req.get(req, url: url, redirect: false, user_agent: "curl"),
         {:ok, result} <- parse(body) do
      {:ok, result}
    else
      {:ok, %Req.Response{status: status, body: body}} -> {:error, "status: #{status}\n#{body}"}
    end
  end

  @spec get!(Req.Request.t(), String.t()) :: Twima.Fxtwi.t()
  def get!(req, url) do
    {:ok, result} = get(req, url)
    result
  end

  @spec parse!(binary()) :: Twima.Fxtwi.t()
  def parse!(body) do
    case parse(body) do
      {:ok, x} -> x
      {:error, err} -> raise err
    end
  end

  @spec parse(binary()) :: {:ok, Twima.Fxtwi.t()} | {:error, term()}
  def parse(body) do
    with {:ok, document} <- Floki.parse_document(body),
         {:ok, url} = attribute(document, "meta[property='og:url'][content]"),
         {:ok, description} = attribute(document, "meta[property='og:description'][content]"),
         {:ok, title} = attribute(document, "meta[property='og:title'][content]") do
      image = attribute(document, "meta[property='og:image'][content]") |> err_to_nil()
      video = attribute(document, "meta[property='og:video'][content]") |> err_to_nil()

      video_mime =
        attribute(document, [
          "meta[property='og:video:type'][content]",
          "meta[property='twitter:player:stream:content_type'][content]"
        ])
        |> err_to_nil()

      {:ok,
       %{
         video: video,
         description: description,
         url: url,
         title: title,
         image: image,
         video_mime: video_mime
       }}
    end
  end

  @spec attribute(Floki.html_doctype(), [String.t()] | String.t()) :: {:ok, String.t()} | :error
  defp attribute(document, attribute_or_attributes)

  defp attribute(document, attributes) when is_list(attributes) do
    Enum.find_value(attributes, {:error, "#{inspect(attributes)} not found"}, fn attr ->
      case document |> Floki.attribute(attr, "content") do
        [] -> false
        [x | _] -> {:ok, x}
      end
    end)
  end

  defp attribute(document, attr) do
    case document |> Floki.attribute(attr, "content") do
      [] -> {:error, "#{attr} not found"}
      [a | _] -> {:ok, a}
    end
  end

  defp err_to_nil({:ok, x}), do: x
  defp err_to_nil({:error, _}), do: nil
end
