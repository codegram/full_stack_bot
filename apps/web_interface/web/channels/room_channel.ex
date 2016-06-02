defmodule WebInterface.RoomChannel do
  use Phoenix.Channel

  def join("rooms:" <> user_id, _params, socket) do
    {:ok, assign(socket, :user_id, user_id)}
  end

  def handle_in("message", %{"body" => body}, socket) do
    {:ok, response} = BotEngine.Bot.query(socket.assigns.user_id, body)

    broadcast! socket, "message", %{
      body: response.message,
      author: "bot",
      action: response.action,
      parameters: response.parameters,
      metadata: response.metadata
    }

    {:noreply, socket}
  end
end
