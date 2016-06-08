defmodule WebInterface.WebhookController do
  use WebInterface.Web, :controller
  alias WebInterface.{Webhook, FullStackFestClient}
  alias BotEngine.Responder.Query
  import Spex


  def recv(conn, req) do
    case Spex.validate(Webhook.request_spec, req) do
      {:ok, webhook} ->
        json conn, dispatch(%Query{
              intent: webhook["result"]["metadata"]["intentName"],
              text:   String.downcase(webhook["result"]["resolvedQuery"]),
              action: webhook["result"]["action"],
              params: webhook["result"]["parameters"]
                            })
      {:error, e} ->
        IO.puts e
        conn |> put_status(422) |> json(%{error: "malformed request"}) |> halt
    end
  end

  defp dispatch(query) do
    reply(BotEngine.Responder.dispatch(query))
  end

  defp reply(text) do
    %{speech: text, displayText: text, data: %{}, contextOut: [], source: "Full Stack Fest Website"}
  end
end
