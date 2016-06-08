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
    talk = describe_talk("Unison")
    assert(talk =~ "Unison: a new programming platform")
    assert(talk =~ "Paul Chiusano")
    assert(talk =~ "huge increases in productivity")
  end

  test "it allows for slight misspellings" do
    assert(describe_talk("server react programming") =~ "Make Reactive Programming on the Server Great Again")
    assert(describe_talk("distributed performance") =~ "Ines Sombra")
    assert(describe_talk("IPFS") =~ "Juan Benet")
  end

  test "it doesn't recognize unknown talks" do
    assert(describe_talk("baking sourdough") =~ "I can't recall")
  end

  defp describe_talk(keyword) do
    use_cassette "speakers" do
      Responder.dispatch(%Query {
            intent: "what's the talk about %",
            action: "talk",
            text: "what's the talk about #{keyword}",
            params: %{
              "talk-keyword" => keyword
            }})
    end
  end
end
