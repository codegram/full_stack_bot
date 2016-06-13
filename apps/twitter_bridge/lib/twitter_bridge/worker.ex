defmodule TwitterBridge.Worker do
  @screen_name "fullstackmaster"
  @max_length 120

  alias TwitterBridge.MessageSplitter

  def start_link do
    Task.start_link(&watch/0)
  end

  defp watch do
    ExTwitter.stream_user
    |> Stream.map(fn(tweet) -> Task.async(fn -> react_on(tweet) end) end)
    |> Enum.to_list
  end

  defp react_on(tweet = %ExTwitter.Model.Tweet{}) do
    if mentioned?(tweet) && author(tweet) != @screen_name && !tweet.retweeted_status do
      respond_to(tweet)
    end
  end

  defp react_on({:follow, %{source: %{screen_name: screen_name}}}) do
    message = "Thanks for following me. Feel free to ask me anything related to @fullstackfest."
    ExTwitter.update("@#{screen_name} #{message}")
  end

  defp react_on(_), do: nil

  defp mentioned?(%{entities: %{user_mentions: mentions}}) do
    mentions
    |> Enum.any?(fn (mention) -> mention[:screen_name] == "fullstackmaster" end)
  end

  defp mentioned?(_), do: false

  defp author(%{user: %{screen_name: author_name}}), do: author_name

  defp respond_to(tweet = %{text: text, id: id}) do
    {:ok, %{message: message}} = BotEngine.Bot.query(author(tweet), String.replace(text, "@#{@screen_name}", ""))
    respond(message, tweet)
  end

  defp respond(message, tweet) do
    MessageSplitter.split(message)
    |> update_statuses(tweet)
  end

  defp update_statuses(messages, tweet), do: update_statuses(messages, tweet, tweet.id)

  defp update_statuses([message | rest], original_tweet, previous_id) do
    status = ExTwitter.update("@#{author(original_tweet)} #{message}", in_reply_to_status_id: previous_id)
    update_statuses(rest, original_tweet, status.id)
  end

  defp update_statuses([], _original_tweet, _previous_id), do: nil
end
