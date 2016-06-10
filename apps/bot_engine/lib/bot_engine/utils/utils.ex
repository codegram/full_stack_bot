defmodule BotEngine.Utils.Utils do

  @moduledoc """
  A collection of functions that can be useful in the project but have no
  special place in any other module.
  """

  @doc """
  Parses a List into a String, joining all elements by commas except the last
  one, which is joined with `"and"`. All connectors can be changed in the
  `options` map.

  Keys accepted by the `options` argument:

  * `:two_words_connector`: used when there are only two elements in the list.
  By default it is `" and "`.
  * `:words_connector`: when there are more than 2 elements, it connects all
  the elements except the last one. By default it is `", "`.
  * `:last_word_connector`: when there are more than 2 elements, it connects
  the last element with the test. By default it is `", and "` (that is, the
  Oxford comma)

  See the examples for how it looks.

  ## Examples
    iex> BotEngine.Utils.Utils.to_sentence([])
    ""
    iex> BotEngine.Utils.Utils.to_sentence([1])
    "1"
    iex> BotEngine.Utils.Utils.to_sentence([1, 2])
    "1 and 2"
    iex> BotEngine.Utils.Utils.to_sentence([1, 2, 3])
    "1, 2, and 3"
  """
  def to_sentence(list, options \\ %{})
  def to_sentence([], _options), do: ""
  def to_sentence(list, _options) when length(list) == 1 do
    enum_to_string(Enum.at(list, 0))
  end

  def to_sentence(list, options) when length(list) == 2 do
    options = Map.merge(to_sentence_defaults, options)

    "#{Enum.at(list, 0)}#{options[:two_words_connector]}#{Enum.at(list, 1)}"
  end

  def to_sentence(list, options) when is_list(list) do
    options = Map.merge(to_sentence_defaults, options)

    to_sentence_multiple_values(Enum.reverse(list), options)
  end

  defp enum_to_string(entry) when is_binary(entry), do: entry
  defp enum_to_string(entry), do: String.Chars.to_string(entry)

  defp to_sentence_multiple_values([ head | tail ], options) do
    Enum.reverse(tail)
    |> Enum.join(options[:words_connector])
    |> Kernel.<>(options[:last_word_connector])
    |> Kernel.<>("#{head}")
  end

  defp to_sentence_defaults do
    %{
      words_connector: ", ",
      two_words_connector: " and ",
      last_word_connector: ", and "
    }
  end
end
