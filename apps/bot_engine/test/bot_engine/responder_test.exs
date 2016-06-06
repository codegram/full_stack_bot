defmodule BotEngine.ResponderTest do
  use ExUnit.Case, async: false
  doctest BotEngine.Responder
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias BotEngine.Responder
  alias BotEngine.Responder.Query

  setup_all do
    BotEngine.FullStackFest.start
  end

  test "it describes speakers" do
    use_cassette "speakers" do
      response = Responder.dispatch(%Query {
            intent: "who is %",
            action: "whois",
            text: "Who is Joe Armstrong?",
            params: %{
              "given-name" => "Joe",
              "last-name" => "Armstrong"
            }})

      assert(response =~ "Erlang language & platform co-creator")
      assert(response =~ "Keynote")
      assert(response =~ "twitter.com/joeerl")
      assert(response =~ "interview is worth a read")
    end
  end

  test "it doesn't recognize unknown speakers" do
    use_cassette "speakers" do
      response = Responder.dispatch(%Query {
            intent: "who is %",
            action: "whois",
            text: "Who is Mark Zuckerberg",
            params: %{
              "given-name" => "Mark",
              "last-name" => "Zuckerberg"
            }})

      assert(response =~ "don't know" or response =~ "don't think")
    end
  end
end
