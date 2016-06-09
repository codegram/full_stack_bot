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
    list_sponsors
  end

  def dispatch(%Query{action: "whois", params: %{"full-name" => fullname}}) do
    case lookup_speaker(fullname) do
      {:none, _} -> i_dont_know(fullname)
      {:one, speaker} -> describe_speaker(speaker)
      {:many, [speaker | speakers]} ->
        all_speakers = Enum.join(Enum.map(speakers, &(&1["name"])), ", ") <> " or #{speaker["name"]}"
        "Do you mean #{all_speakers}? Ask me again."
    end
  end

  def dispatch(%Query{action: "talk", params: %{"talk-keyword" => keyword}}) do
    case lookup_talk(keyword) do
      nil ->
        "I can't recall any talk about #{keyword}, but definitely double-check on the agenda: https://2016.fullstackfest.com/agenda"
      talk -> describe_talk(talk)
    end
  end

  def dispatch(_), do: wat

  defp list_sponsors do
    resp = FullStackFest.get!("/sponsors.json").body["categories"] |>
      Enum.reject(fn(cat) -> Enum.count(cat["sponsors"]) == 0 end) |>
      Enum.map(fn(cat) ->
        formatted_sponsors = cat["sponsors"] |> Enum.map(fn(sponsor) ->
          "#{sponsor["name"]} (#{sponsor["website"]})"
        end) |> Enum.join(", ")
        "Our " <> cat["name"] <> " sponsors are " <> formatted_sponsors <> "."
      end) |>
      Enum.join(" ")

    resp <> ". We're very lucky to have them :)"
  end

  defp lookup_talk(keyword) do
    candidates = FullStackFest.get!("/speakers.json").body["speakers"] |>
      Enum.reject(fn(speaker) -> String.contains?(speaker["talk"]["title"], "Master of Cerimonies") end) |>
      Enum.map(fn(speaker) ->
        {similarity_score(
            String.downcase(speaker["talk"]["title"]),
            String.downcase(speaker["talk"]["description"]),
            String.downcase(keyword)), speaker}
      end) |>
      Enum.sort |>
      Enum.reject(fn({score, _}) -> score < 0.7 end) |>
      Enum.map(fn({_, speaker}) -> speaker end) |>
      Enum.reverse
    List.first(candidates)
  end

  defp lookup_speaker(name) do
    candidates = FullStackFest.get!("/speakers.json").body["speakers"] |>
      Enum.map(fn(speaker) ->
        {String.jaro_distance(String.downcase(name), String.downcase(speaker["name"])), speaker}
      end) |>
      Enum.sort |>
      Enum.reject(fn({score, _}) -> score < 0.7 end) |>
      Enum.reverse |>
      Enum.reduce({0, []}, fn({score, speaker}, {max_score, acc}) ->
        new_score = if score > max_score, do: score, else: max_score
        new_acc = if (new_score - score) > 0.2, do: acc, else: [speaker | acc]
        {new_score, new_acc}
      end) |>
      Tuple.to_list |>
      List.last |>
      Enum.reverse
    case Enum.count(candidates) do
      0 -> {:none, nil}
      1 -> {:one, List.first(candidates)}
      _ -> {:many, Enum.take(candidates, 3)}
    end
  end

  defp describe_speaker(speaker) do
    speaker["tagline"] <> " " <>
      speaker["name"] <> " will be speaking about " <> speaker["talk"]["title"] <> "." <>
      " Read more about them at https://2016.fullstackfest.com/speakers/" <> speaker["slug"] <> "." <>
    (if speaker["twitter"], do: " Oh, and you should follow them on twitter at " <> speaker["twitter"] <> "!", else: "") <>
    (if speaker["interview"], do: " Their interview is worth a read as well: " <> speaker["interview"], else: "")
  end

  defp describe_talk(speaker) do
    description = speaker["talk"]["description"]
    speaker["name"] <> " is going to talk about " <> speaker["talk"]["title"] <> "." <>
    (if String.length(description) != 0 do
      " Here's the description of the talk: " <> description
    else
      ""
    end)
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

  defp similarity_score(title, description, keyword) do
    title_tokens = tokenize(title)
    desc_tokens = tokenize(description)
    keyword_tokens = tokenize(keyword)

    title_freqs = Enum.map(keyword_tokens, fn(t) -> freq(t, title_tokens) end)
    desc_freqs = Enum.map(keyword_tokens, fn(t) -> freq(t, desc_tokens) end)

    title_freqs_sum = Enum.sum(title_freqs)
    desc_freqs_sum = Enum.sum(desc_freqs)

    mc = (if String.contains?(title, "Master of Cerimonies"), do: 0, else: 1)
    weight = (title_freqs_sum * 0.5) + 1
    desc_weight = (desc_freqs_sum * 0.2) + 1

    mc * weight * desc_weight * String.jaro_distance(keyword, title)
  end

  defp tokenize(string) do
    string |>
      String.replace(~r/[\.,!\?\(\)-]/, "") |>
      String.replace("/", " ") |>
      String.split |>
      Enum.reject(fn(t) -> String.length(t) < 3 end)
  end

  defp freq(token, tokens) do
    tokens |>
      Enum.filter(fn(t) -> t == token end) |>
      Enum.count
  end
end
