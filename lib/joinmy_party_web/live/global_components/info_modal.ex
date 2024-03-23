defmodule JoinmyPartyWeb.InfoModal do
  use Phoenix.LiveComponent

  def mount(socket), do: {:ok, assign(socket, :open, false)}

  def render(assigns = %{open: true}) do
    ~H"""
    <div class="modal">
      <button phx-click="close" class="close-btn">✖</button>
      <div class="modal-header">
        <%= render_slot(@header) || "Modal" %>
      </div>
      <div class="modal-body">
        <%= render_slot(@inner_block) %>
      </div>
      <div class="modal-footer">
        <%= render_slot(@footer) %>
      </div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    """
  end

  def handle_event("close", _, socket) do
    {:noreply, assign(socket, :open, false)}
  end

  def handle_event("open", _, socket) do
    {:noreply, assign(socket, :open, true)}
  end

end
