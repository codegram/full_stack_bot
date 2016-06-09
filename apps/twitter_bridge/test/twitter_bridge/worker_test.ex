defmodule TwitterBridge.WorkerTest do
  use ExUnit.Case
  doctest TwitterBridge.Worker
  alias TwitterBridge.Worker

  test "pack strings" do
    Worker.pack_strings("Joe Armstrong (The Erlang language & platform co-creator.) will be speaking about Keynote. Read more about them at https://2016.fullstackfest.com/speakers/joe-armstrong . Oh, and you should follow them on twitter at https://twitter.com/joeerl ! Their interview is worth a read as well: https://medium.com/@FullStackFest/interviewing-joe-armstrong-8b7d2023d975")
    |> IO.inspect
  end
end
