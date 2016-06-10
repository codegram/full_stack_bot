defmodule BotEngine.Utils.SentenceTest do
  use ExUnit.Case, async: false
  doctest BotEngine.Utils.Sentence

  alias BotEngine.Utils.Sentence

  test "it returns an empty string when list is empty" do
    values = []
    result = Sentence.to_sentence(values)

    assert(result == "")
  end

  test "it returns the value as string when there is only one" do
    values = [1]
    result = Sentence.to_sentence(values)

    assert(result == "1")
  end

  test "it joins the values with connector when there are only two" do
    values = [1, 2]
    result = Sentence.to_sentence(values)

    assert(result == "1 and 2")
  end

  test "it joins the values with different connectors when there are more than two" do
    values = [1, 2, 3]
    result = Sentence.to_sentence(values)

    assert(result == "1, 2, and 3")
  end

  test "it uses custom connectors when provided" do
    single_value_result = Sentence.to_sentence([1], custom_sentence_connectors)
    two_values_result = Sentence.to_sentence([1, 2], custom_sentence_connectors)
    multiple_values_result = Sentence.to_sentence([1, 2, 3], custom_sentence_connectors)

    assert(single_value_result == "1")
    assert(multiple_values_result == "1 - 2 && 3")
    assert(two_values_result == "1 || 2")
  end

  defp custom_sentence_connectors do
    %{
      words_connector: " - ",
      two_words_connector: " || ",
      last_word_connector: " && "
    }
  end
end
