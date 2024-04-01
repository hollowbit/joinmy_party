defmodule PdilemmaWeb.RoundEndModal do
  # In Phoenix apps, the line is typically: use MyAppWeb, :html
  use Phoenix.LiveComponent

  def mount(socket) do
    state = %{
      open: false,
      last_round_selection: :defect,
      other_team_selection: :defect,
      last_round_points_earned: 0,
      round: 1
    }

    {:ok, assign(socket, state) }
  end

  def render(assigns) do
    ~H"""
    <dialog class="w-10/12 max-w-2xl rounded-lg shadow-md shadow-slate-800 text-slate-700 backdrop-blur-2xl" phx-click="close-modal" phx-target={@myself} open={@open} id="pdilemma-round-end-modal">
        <div class="w-full h-full flex flex-col items-center p-6">
          <span class="top-2 right-2 mr-2 font-bold text-3xl text-slate-700 cursor-pointer absolute" >✖</span>
          <.round_result_html {assigns} />
          <button class=" w-3/4 mt-7 rounded-lg bg-emerald-400 text-slate-50 font-bold text-center px-4 py-2 border-emerald-600 border-r-2 border-b-2">Continue to Round <%= @round %></button>
        </div>
    </dialog>
    """
  end

  def round_result_html(assigns) do
    case {assigns.last_round_selection, assigns.other_team_selection} do
      {:cooperate, :cooperate} ->
        ~H"""
        <h2 class="text-center text-4xl mt-8">Both teams <span class="text-green-500">COOPERATED</span>!</h2>
        <p class="text-center text-xl text-slate-600 m-3">+<%= @last_round_points_earned %> points 🙌</p>
        """

      {:cooperate, :defect} ->
        ~H"""
        <h2 class="text-center text-4xl mt-8">They <span class="text-red-500">DEFECTED</span>!</h2>
        <p class="text-center text-xl text-slate-600 m-3"><%= @last_round_points_earned %> points 😭</p>
        """

      {:defect, :cooperate} ->
        ~H"""
        <h2 class="text-center text-4xl mt-8">Hehehe, they <span class="text-green-500">COOPERATED</span>!</h2>
        <p class="text-center text-xl text-slate-600 m-3">+<%= @last_round_points_earned %> points 😈</p>
        """

      {:defect, :defect} ->
        ~H"""
        <h2 class="text-center text-4xl mt-8">Both teams <span class="text-red-500">DEFECTED</span>!</h2>
        <p class="text-center text-xl text-slate-600 m-3"><%= @last_round_points_earned %> points 🔪</p>
        """

      _ ->
        ~H"""
        <h2 class="text-center text-4xl mt-8">Unknown Round Result</h2>
        """
    end
  end

  def update(assigns = %{open: true}, socket) do
    {:ok, push_event_show_modal(assign(socket, assigns))}
  end

  def update(assigns = %{open: false}, socket) do
    {:ok, push_event_close_modal(assign(socket, assigns))}
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def handle_event("close-modal", _, socket) do
    {:noreply, assign(socket, :open, false) |> push_event_close_modal}
  end

  def handle_event("show-modal", _, socket) do
    {:noreply, assign(socket, :open, true) |> push_event_show_modal}
  end

  defp push_event_show_modal(socket) do
    push_event(socket, "show-modal", %{to: "pdilemma-round-end-modal"})
  end

  defp push_event_close_modal(socket) do
    push_event(socket, "close-modal", %{to: "pdilemma-round-end-modal"})
  end

end
