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

  test "it allows for slight misspellings in the speaker's name" do
    use_cassette "speakers" do
      response = Responder.dispatch(%Query {
            intent: "who is %",
            action: "whois",
            text: "Who is Joel Armstong?",
            params: %{
              "given-name" => "Joel",
              "last-name" => "Armstong"
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

  test "it describes talks" do
    use_cassette "speakers" do
      response = Responder.dispatch(%Query {
            intent: "what's the talk about %",
            action: "talk",
            text: "what's the talk about Unison?",
            params: %{
              "talk-keyword" => "Unison"
            }})

      assert(response =~ "Unison: a new programming platform")
      assert(response =~ "Paul Chiusano")
      assert(response =~ "huge increases in productivity")
    end
  end

  test "it allows for slight misspellings" do
    use_cassette "speakers" do
      response = Responder.dispatch(%Query {
            intent: "what's the talk about %",
            action: "talk",
            text: "what's the talk about server react programming",
            params: %{
              "talk-keyword" => "server react programming"
            }})

      assert(response =~ "Make Reactive Programming on the Server Great Again")
    end
  end

  test "it doesn't recognize unknown talks" do
    use_cassette "speakers" do
      response = Responder.dispatch(%Query {
            intent: "what's the talk about %",
            action: "talk",
            text: "what's the talk about baking sourdough",
            params: %{
              "talk-keyword" => "baking sourdough"
            }})

      assert(response =~ "I don't know")
    end
  end
end
