defmodule BotEngine.ResponderTest do
  use ExUnit.Case, async: false
  doctest BotEngine.Responder
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias BotEngine.Responder
  alias BotEngine.Responder.Query

  setup_all do
    BotEngine.FullStackFest.start
  end

  test "it describes speakers by full name" do
    joe = describe_speaker("Joe Armstrong")
    assert(joe =~ "Erlang language & platform co-creator")
    assert(joe =~ "Keynote")
    assert(joe =~ "twitter.com/joeerl")
    assert(joe =~ "fullstackfest.com/speakers/joe-armstrong")
    assert(joe =~ "interview is worth a read")
  end

  test "it describes speakers by first name only" do
    joe = describe_speaker("simon")
    assert(joe =~ "Leading Shopify's core architecture team")
  end

  test "it allows for slight misspellings in the speaker's name" do
    joe = describe_speaker("joel amstong")
    assert(joe =~ "Erlang language & platform co-creator")
    assert(joe =~ "Keynote")
    assert(joe =~ "twitter.com/joeerl")
    assert(joe =~ "interview is worth a read")
  end

  test "it allows for ambiguities matching several speakers" do
    joe = describe_speaker("david")
    assert(joe =~ "Do you mean David Simons or David Wells?")
  end

  test "it doesn't recognize unknown speakers" do
    unknown = describe_speaker("Mark Zuckerberg")
    assert(unknown =~ "don't know" or unknown =~ "don't think")
  end

  test "it describes talks" do
    talk = describe_talk("Unison")
    assert(talk =~ "Unison: a new programming platform")
    assert(talk =~ "Paul Chiusano")
    assert(talk =~ "huge increases in productivity")
  end

  test "it allows for ambiguous talk queries" do
    assert(describe_talk("elm") =~ "Confident Frontend with Elm")
  end

  test "it allows for slight misspellings" do
    assert(describe_talk("server react programming") =~ "Make Reactive Programming on the Server Great Again")
    assert(describe_talk("performance") =~ "Ines Sombra")
    assert(describe_talk("IPFS") =~ "Juan Benet")
  end

  test "it doesn't recognize unknown talks" do
    assert(describe_talk("baking sourdough") =~ "I can't recall")
  end

  test "it knows who speaks about a specific topic" do
    assert(who_speaks_about("unison") =~ "Paul Chiusano")
    assert(whats_x_talking_about("paul chiusano") =~ "Unison")
  end

  test "it lists all our sponsors" do
    sponsors = list_sponsors
    assert(sponsors =~ "Pusher")
    assert(sponsors =~ "black_hat")
    assert(sponsors =~ "pusher.com")
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

  defp describe_speaker(name) do
    use_cassette "speakers" do
      Responder.dispatch(%Query {
            intent: "who is %",
            action: "whois",
            text: "who is #{name}",
            params: %{
              "full-name" => name
            }})
    end
  end

  defp who_speaks_about(topic) do
    use_cassette "speakers" do
      Responder.dispatch(%Query {
            intent: "Who speaks about X",
            action: "whospeaksabout",
            text: "who speaks about #{topic}?",
            params: %{"talk-keyword" => topic}})
    end
  end

  defp whats_x_talking_about(name) do
    use_cassette "speakers" do
      Responder.dispatch(%Query {
            intent: "What's x talking about",
            action: "whatsxtalkingabout",
            text: "what's #{name} talking about?",
            params: %{"full-name" => name}})
    end
  end

  defp list_sponsors do
    use_cassette "sponsors" do
      Responder.dispatch(%Query {
            intent: "Sponsors",
            action: "sponsors",
            text: "who are your sponsors?",
            params: %{}})
    end
  end
end
