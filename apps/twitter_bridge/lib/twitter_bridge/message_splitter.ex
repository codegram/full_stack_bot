defmodule TwitterBridge.MessageSplitter do
  @max_length 120

  def split("", _), do: []

  def split(text, max_length \\ @max_length) do
    text
    |> split_in_words(max_length)
    |> create_messages(max_length)
  end

  defp create_messages([word | rest_words], max, messages = [message | rest_messages] \\ [""]) do
    if String.length("#{message} #{word}") > max do
      create_messages(rest_words, max, [word | [message | rest_messages]])
    else
      new_message = String.strip("#{message} #{word}")
      create_messages(rest_words, max, [new_message | rest_messages])
    end
  end

  defp create_messages([], _, messages), do: Enum.reverse(messages)

  defp split_in_words(text, max_length) do
    String.split(text, " ")
    |> break_big_words(max_length)
  end

  defp break_big_words([word | rest], max_length) do
    if String.length(word) > max_length do
      {word1, word2} = String.split_at(word, max_length)

      [word1 | break_big_words([word2 | rest], max_length)]
    else
      [word | break_big_words(rest, max_length)]
    end
  end

  defp break_big_words([], _), do: []
end
