defmodule TwitterBridge.MessageSplitterTest do
  use ExUnit.Case
  use ExCheck

  doctest TwitterBridge.MessageSplitter
  alias TwitterBridge.MessageSplitter

  property :breaks_all_messages_under_length do
    for_all x in message do
      messages = MessageSplitter.split(x, 140)

      Enum.all?(messages, fn (element) -> String.length(element) <= 140 end)
    end
  end

  property :parent_message_can_be_reconstructed do
    for_all x in message do
      String.strip(MessageSplitter.split(x, 140) |> Enum.join(" ")) == String.strip(x)
    end
  end

  defp message do
    bind(list(word), &(Enum.join(&1, " ")))
  end

  def word(min \\ 1, max \\ 20) do
    bind(such_that(xx in list(char) when Enum.count(xx) < max and Enum.count(xx) >= min), &List.to_string/1)
  end
end
