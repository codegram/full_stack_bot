defmodule BotEngine.ApiAiTest do
  use ExUnit.Case, async: false
  doctest BotEngine
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias BotEngine.ApiAi

  setup_all do
    HTTPoison.start
  end

  test "it replies to a user's questions" do
    use_cassette "when_is_the_conference" do
      {:ok, %{message: message}} = ApiAi.query(0, "when is the conference taking place?")

      assert(message |> String.contains?("September"))
    end

    use_cassette "where_is_the_conference" do
      {:ok, %{message: message}} = ApiAi.query(0, "where does the conference take place?")

      assert(message |> String.contains?("Auditori Axa"))
    end
  end
end
