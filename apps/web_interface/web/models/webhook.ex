defmodule WebInterface.Webhook do
  use Spex.DSL

  def request_spec do
    %{
      "asr" => optional(any),
      "status" => %{
        "code" => number,
        "message" => optional(string)
      },
      "alternateResult" => optional(map),
      "result" => %{
        "score" => number,
        "source" => "agent",
        "resolvedQuery" => string,
        "speech" => optional(string),
        "action" => string,
        "actionIncomplete" => boolean,
        "parameters" => map,
        "contexts" => [
          %{
            "name" => string,
            "parameters" => map,
            "lifespan" => number,
          }
        ],
        "metadata" => %{
          "intentId" => string,
          "webhookUsed" => string,
          "intentName" => string,
        },
        "fulfillment" => %{
          "speech" => string,
          "source" => optional(string),
          "displayText" => optional(string),
          "data" => optional(string)
        }
      }
    }
  end

  def response_spec do
    %{
      "speech" => string,
      "displayText" => string,
      "data" => map,
      "contextOut" => [map(string, any)],
      "source" => string,
    }
  end
end
