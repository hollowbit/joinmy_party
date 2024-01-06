defmodule JoinmyPartyWeb.PdilemmaLive do
  # In Phoenix v1.6+ apps, the line is typically: use MyAppWeb, :live_view
  use Phoenix.LiveView

  @topic "pdilemma"

  def render(assigns) do
    ~H"""
    <button phx-click="change_selection">
      <%= case @selection_x_not_y do
        true -> "X"
        false -> "Y"
        end %>
        <small>(click to change)</small>
    </button>
    """
  end

  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(JoinmyParty.PubSub, @topic)
    selection_x_not_y = true
    {:ok, assign(socket, :selection_x_not_y, selection_x_not_y)}
  end

  def handle_event("change_selection", _params, socket) do
    Phoenix.PubSub.broadcast(JoinmyParty.PubSub, @topic, {:update_selection, !socket.assigns.selection_x_not_y})
    {:noreply, socket}
  end

  def handle_info({:update_selection, selection_x_not_y}, socket) do
    {:noreply, assign(socket, :selection_x_not_y, selection_x_not_y)}
  end


end
