defmodule BotEngine.Responder do
  alias BotEngine.FullStackFest
  alias BotEngine.Similarity

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
      {:many, speakers} -> disambiguate(speakers, &(&1["name"]))
    end
  end

  def dispatch(%Query{action: "whospeaksabout", params: %{"talk-keyword" => keyword}}) do
    case lookup_talk(keyword) do
      {:none, _} ->
        "I can't recall any talk about #{keyword}, but definitely double-check on the agenda: https://2016.fullstackfest.com/agenda"
      {:one, speaker} -> describe_speaker(speaker)
      {:many, speakers} -> disambiguate(speakers, &(&1["talk"]["title"]))
    end
  end

  def dispatch(%Query{action: "whatsxtalkingabout", params: %{"full-name" => fullname}}) do
    case lookup_speaker(fullname) do
      {:none, _} -> i_dont_know(fullname)
      {:one, speaker} -> describe_talk(speaker)
      {:many, speakers} -> disambiguate(speakers, &(&1["name"]))
    end
  end

  def dispatch(%Query{action: "talk", params: %{"talk-keyword" => keyword}}) do
    case lookup_talk(keyword) do
      {:none, _} ->
        "I can't recall any talk about #{keyword}, but definitely double-check on the agenda: https://2016.fullstackfest.com/agenda"
      {:one, speaker} -> describe_talk(speaker)
      {:many, speakers} -> disambiguate(speakers, &(&1["talk"]["title"]))
    end
  end

  def dispatch(_), do: wat

  defp list_sponsors do
    resp = FullStackFest.get!("/sponsors.json").body["categories"] |>
      Enum.reject(&(Enum.empty?(&1["sponsors"]))) |>
      Enum.map(fn(%{"sponsors" => sponsors, "name" => category_name}) ->
        formatted_sponsors = sponsors |> Enum.map(fn(%{"name" => name, "website" => website}) ->
          "#{name} (#{website})"
        end) |> Enum.join(", ")
        formatted_category = category_name |>
          String.split("_") |>
          Enum.map(&String.capitalize/1) |>
          Enum.join(" ")

        "Our #{formatted_category} sponsors are #{formatted_sponsors}."
      end) |>
      Enum.join(" ")

    resp <> " We're very lucky to have them :)"
  end

  defp lookup_talk(query) do
    speakers = FullStackFest.get!("/speakers.json").body["speakers"] |>
      Enum.reject(fn(%{"talk" => %{"title" => title}}) -> String.contains?(title, "Master of Cerimonies") end)

    Similarity.query(query, speakers,
      fn(query, %{"talk" => %{"title" => title, "description" => description, "keywords" => keywords}}) ->
        talk_similarity(query, title, description, keywords)
      end,
      %{min_confidence: 0.5,
        max_distance_from_best: 0.1}
    )
  end

  defp lookup_speaker(name) do
    speakers = FullStackFest.get!("/speakers.json").body["speakers"]
    Similarity.query(name, speakers,
      fn(name, %{"name" => speaker_name}) ->
        String.jaro_distance(String.downcase(name), String.downcase(speaker_name))
      end,
      %{min_confidence: 0.7,
        max_distance_from_best: 0.2}
    )
  end

  defp describe_speaker(%{"tagline" => tagline,
                          "name" => name,
                          "slug" => slug,
                          "twitter" => twitter,
                          "talk" => %{ "title" => talk_title }} = talk) do
    "#{name} (#{tagline}) will be speaking about #{talk_title}. " <>
      "Read more about them at https://2016.fullstackfest.com/speakers/#{slug} ." <>
    (if twitter, do: " Oh, and you should follow them on twitter at #{twitter} !", else: "") <>
    (if talk["interview"], do: " Their interview is worth a read as well: #{talk["interview"]}", else: "")
  end

  defp describe_talk(%{"name" => name,
                       "talk" => %{"description" => description,
                                   "title" => talk_title}}) do
    "#{name} is going to talk about #{talk_title}." <>
      (if String.length(description) != 0 do
        " Here's the description of the talk: \"#{description}\"."
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

  defp disambiguate([value | values], show_function) do
    alternatives = (values |>
      Enum.map(&(show_function.(&1))) |>
      Enum.join(", ")) <>
      " or #{show_function.(value)}"
    "Do you mean #{alternatives}? Ask me again."
  end

  defp talk_similarity(query, title, description, keywords) do
    title_distance = String.jaro_distance(String.downcase(query), String.downcase(title))
    title_fsum = 1 - ( 1 / (1 + (Similarity.Text.freq_sum(query, title) * 2)))
    desc_fsum = 1 - ( 1 / (1 + (Similarity.Text.freq_sum(query, description))))
    keywords_fsum = 1 - (1 / (1 + Similarity.Text.freq_sum(query, keywords) * 5))

    title_fsum * 0.5 + title_distance * 0.2 + desc_fsum * 0.3 + keywords_fsum
  end
end
