defmodule BotEngine.Bot do
  @adapter BotEngine.ApiAi

  def query(session_id, message) do
    @adapter.query(session_id, message)
  end
end
