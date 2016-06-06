defmodule BotEngine.FullStackFest do
  use HTTPoison.Base
  use Spex.DSL

  @base_url "https://2016.fullstackfest.com"

  def speakers do
    Spex.validate!([speaker_spec], get!("/speakers.json").body["speakers"])
  end

  def process_url(url) do
    @base_url <> url
  end

  defp process_response_body(body), do: Poison.decode!(body)

  defp speaker_spec do
    %{"talk" => %{ "title" => string, "description" => string },
      "name" => string,
      "slug" => string,
      "track" => string,
      "twitter" => string,
      "tagline" => string}
  end
end
