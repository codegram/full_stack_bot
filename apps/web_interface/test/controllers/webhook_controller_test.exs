defmodule WebInterface.WebhookControllerTest do
  use WebInterface.ConnCase
  alias WebInterface.Webhook

  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  def example_request do
    example_request("bar", "nonsense", "foo")
  end

  def example_request(action, intent, query) do
    Spex.validate!(Webhook.request_spec, %{
      "result" => %{
        "source" => "agent",
        "resolvedQuery" => query,
        "speech" => nil,
        "action" => action,
        "actionIncomplete" => false,
        "parameters" => %{},
        "contexts" => [],
        "metadata" => %{
          "intentId" => "03d5abba-1720-4a58-a682-411cf43e78a4",
          "webhookUsed" => "true",
          "intentName" => intent
        },
        "fulfillment" => %{
          "speech" => "You can check out the agenda with all the talks and speakers at https://2016.fullstackfest.com/agenda",
          "source" => nil,
          "displayText" => nil,
          "data" => nil
        },
        "score" => 1
      },
      "alternateResult" => nil,
      "status" => %{
        "code" => 200,
        "message" => nil
      },
      "asr" => nil
    })
  end

  test "POST /webhook returns a valid Webhook response" do
    conn = post conn(), "/webhook", example_request
    resp = json_response(conn, 200)
    assert Spex.validate!(Webhook.response_spec, resp)
  end

  test "speakers tells you about speakers" do
    conn = post conn(), "/webhook", example_request("agenda", "Agenda", "Who is speaking?")
    resp = json_response(conn, 200)
    assert Spex.validate!(Webhook.response_spec, resp)["speech"] =~ "Check out the full agenda"
  end
end
