defmodule BotEngine.Similarity do
  @moduledoc """
    A module to retrieve a document by similarity within a corpus of documents.
  """

  @doc """
    Retrieves one, many or no documents from a `corpus` using a query `q`.

    The algorithm is as follows:

      1. Score every document with `score_function/2` (which takes the
         query and the document)
      2. Rejects the documents whose score is less than the `min_confidence`
         threshold
      3. Reject the documents that are below the best score by more than `max_distance_from_best`
      4. Return either:
         a) {:none, nil} if there was no reasonable match,
         b) {:one, best_candidate} if there was one clear match,
         c) {:many, up_to_three_best_candidates} if there was more than one good candidate

    ## Examples

        iex> BotEngine.Similarity.query(                    \
          "John",                                           \
          ["Jonathan", "Rick", "Amanda", "Johnny"],         \
          fn(q, name) -> String.jaro_distance(q, name) end, \
          %{min_confidence: 0.8,                            \
            max_distance_from_best: 0.2}                    \
        )
        {:one, "Johnny"}

  """
  def query(q, corpus, score_function, %{min_confidence: min_confidence,
                                         max_distance_from_best: max_distance_from_best}) do
    candidates = corpus |>
      Enum.map(fn(document) -> {score_function.(q, document), document} end) |>
      Enum.sort |>
      Enum.reject(fn({score, _}) -> score < min_confidence end) |>
      Enum.reverse |>
      Enum.reduce({0, []}, fn({score, document}, {max_score, acc}) ->
        new_score = if score > max_score, do: score, else: max_score
        new_acc = if (new_score - score) > max_distance_from_best, do: acc, else: [document | acc]
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

  defmodule Text do
    @moduledoc """
    Text-specific functions to determine similarity between keywords and text documents.
    """

    @doc """
    Returns the frequency of a token within a list of tokens.

    ## Examples

    iex> BotEngine.Similarity.Text.frequency("foo", ["bar", "foo", "foo"])
    2

    """
    def frequency(token, tokens) do
      tokens |>
        Enum.filter(fn(t) -> t == token end) |>
        Enum.count
    end

    @doc """
    Tokenize a string into tokens of length 3 or more.

    ## Examples

    iex> BotEngine.Similarity.Text.tokenize("foo, Bar? baz. heyo in a box!!")
    ["foo", "bar", "baz", "heyo", "box"]

    """
    def tokenize(string) do
      string |>
        String.downcase |>
        String.replace(~r/[\.,!\?\(\)-]/, "") |>
        String.replace("/", " ") |>
        String.split |>
        Enum.reject(fn(t) -> String.length(t) < 3 end)
    end

    @doc """
      Returns the sum of frequencies of a query `q`'s tokens within a text.

      ## Examples

          iex> BotEngine.Similarity.Text.freq_sum("foo bar", "foo, bar, baz, bar haha")
          3

    """
    def freq_sum(q, text) do
      text_tokens = tokenize(text)
      tokenize(q) |> Enum.map(fn(t) -> frequency(t, text_tokens) end) |> Enum.sum
    end
  end
end
