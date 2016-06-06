defmodule BotEngine.Responder do
  alias BotEngine.FullStackFest

  defmodule Query do
    defstruct [:intent, :text, :action, :params]
  end

  @wats [
    "Can you rephrase? I'm not sure what you mean.",
    "Uhm what's that again?",
    "No idea what you mean."
  ]

  def dispatch(%Query{action: "agenda"}) do
    "Check out the full agenda at https://2016.fullstackfest.com/agenda."
  end

  def dispatch(%Query{action: "accommodation"}) do
    "The venue is so cool that there are 3 hotels within 5 minutes walking distance! Check out​ https://2016.fullstackfest.com/tickets/#accommodation to see the available options."
  end

  # TODO: During the conference, provide a phone number
  def dispatch(%Query{action: "contact"}) do
    "You can contact the organizers through conferences@codegram.com or via Twitter (@fullstackfest)"
  end

  def dispatch(%Query{action: "discount"}) do
    "Just because it's you. Use the code FMASTER for a 5% discount or just go to https://ti.to/codegram/full-stack-fest-2016/discount/FMASTER"
  end

  def dispatch(%Query{action: "commands"}) do
    "Ask me about Full Stack Fest's agenda, speakers, contact information, a specific talk topic you'd like to know more about -- pretty much anything. Don't be shy."
  end

  def dispatch(%Query{action: "buy"}) do
    "Looking for tickets? That's great! You can get more information about available tickets at https://2016.fullstackfest.com/tickets/ or buy them here: https://ti.to/codegram/full-stack-fest-2016"
  end

  # TODO: During the conference, point people to the right party.
  def dispatch(%Query{action: "party"}) do
    "There will be, not one, but two parties! And also two meetups! Every day after the talks you get to hang out with everyone! Check out the agenda https://2016.fullstackfest.com/agenda/ and the venues: https://2016.fullstackfest.com/tickets/#venue"
  end

  def dispatch(%Query{action: "sponsoring"}) do
    "Nice to hear you're interested in sponsoring us! You can check our sponsorship packages here: https://2016.fullstackfest.com/sponsors/"
  end

  def dispatch(%Query{action: "sponsors"}) do
    "There's a list of sponsors in the bottom of our page: https://2016.fullstackfest.com/"
  end

  def dispatch(%Query{action: "whois", params: %{"given-name" => firstname, "last-name" => lastname}}) do
    fullname = firstname <> " " <> lastname
    case lookup_speaker(fullname) do
      nil -> i_dont_know(fullname)
      speaker -> describe_speaker(speaker)
    end
  end

  def dispatch(_), do: wat

  defp lookup_speaker(name) do
    Enum.find(FullStackFest.get!("/speakers.json").body["speakers"], fn(speaker) ->
      speaker["name"] == name
    end)
  end

  defp describe_speaker(speaker) do
    speaker["tagline"] <>
      "They're speaking about " <> speaker["talk"]["title"] <> ". " <>
    (if speaker["twitter"], do: "You should follow them on twitter: " <> speaker["twitter"] <> "!", else: "") <>
    (if speaker["interview"], do: "Also, their interview is worth a read: " <> speaker["interview"], else: "")
  end

  defp wat do
    Enum.random(@wats)
  end

  defp i_dont_know(name) do
    Enum.random([
      "I don't think I've ever heard of #{name}... I'm sure they're great fun though.",
      "Uhm... #{name}? I'm afraid if you're not talking about that TV presenter from the mid-80s, I don't know who that is.",
      "The name rings a bell, but I don't think I've ever met #{name}, sorry."
    ])
  end
end
