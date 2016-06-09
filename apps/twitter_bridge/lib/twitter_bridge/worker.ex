defmodule TwitterBridge.Worker do
  @screen_name "fullstackmaster"
  @max_length 120

  def start_link do
    Task.start_link(&watch/0)
  end

  defp watch do
    ExTwitter.stream_user
    |> Stream.map(fn(tweet) -> Task.async(fn -> react_on(tweet) end) end)
    |> Enum.to_list
  end

  defp react_on(tweet = %ExTwitter.Model.Tweet{}) do
    if mentioned?(tweet) && author(tweet) != @screen_name do
      respond_to(tweet)
    end
  end

  defp react_on(_), do: nil

  defp mentioned?(%{entities: %{user_mentions: mentions}}) do
    mentions
    |> Enum.any?(fn (mention) -> mention[:screen_name] == "fullstackmaster" end)
  end

  defp mentioned?(_), do: false

  defp author(%{user: %{screen_name: author}}), do: author

  defp respond_to(tweet = %{text: text, id: id}) do
    {:ok, %{message: message}} = BotEngine.Bot.query(author(tweet), String.replace(text, @screen_name, ""))
    respond(message, tweet)
  end

  defp respond(message, tweet) do
    pack_strings(message)
    |> IO.inspect
    |> update_statuses(tweet)
  end

  def pack_strings(message) do
    message
    |> String.split(" ")
    |> create_messages(@max_length)
  end

  def create_messages([word | rest_words], max, messages = [message | rest_messages] \\ [""]) do
    if String.length("#{message} #{word}") > max do
      create_messages(rest_words, max, [word | [message | rest_messages]])
    else
      new_message = String.strip("#{message} #{word}")
      create_messages(rest_words, max, [new_message | rest_messages])
    end
  end

  def create_messages([], _, messages), do: Enum.reverse(messages)

  defp update_statuses(messages, tweet), do: update_statuses(messages, tweet, tweet.id)

  defp update_statuses([message | rest], original_tweet, previous_id) do
    status = ExTwitter.update("@#{author(original_tweet)} #{message}", in_reply_to_status_id: previous_id)
    update_statuses(rest, original_tweet, status.id)
  end

  defp update_statuses([], _original_tweet, _previous_id), do: nil
end
