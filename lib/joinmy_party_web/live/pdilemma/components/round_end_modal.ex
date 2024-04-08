defmodule PdilemmaWeb.RoundEndModal do
  alias JoinmyPartyWeb.CoreComponents
  alias Phoenix.LiveView.JS
  # In Phoenix apps, the line is typically: use MyAppWeb, :html
  use Phoenix.LiveComponent
  import JoinmyPartyWeb.Tools.JsInteropTools


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
    <div>
    <JoinmyPartyWeb.CoreComponents.modal id="pdilemma-round-end-modal">
        <div class="flex flex-col items-center p-6">
          <.round_result_html {assigns} />
          <button class=" w-3/4 mt-7 rounded-lg bg-emerald-400 text-slate-50 font-bold text-center px-4 py-2 border-emerald-600 border-r-2 border-b-2" phx-click={JS.exec("data-cancel", to: "#pdilemma-round-end-modal")}>Continue to Round <%= @round %></button>
        </div>
    </JoinmyPartyWeb.CoreComponents.modal>
    </div>
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
    {:ok, assign(socket, assigns |> Map.delete(:open)) |> show_modal()}
  end

  def update(assigns = %{open: false}, socket) do
    {:ok, assign(socket, assigns |> Map.delete(:open)) |> hide_modal()}
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def handle_event("close-modal", _, socket) do
    {:noreply, socket |> hide_modal()}
  end

  def handle_event("show-modal", _, socket) do
    {:noreply, socket |> show_modal()}
  end

  defp show_modal(socket) do
    socket
    |> push_js("pdilemma-round-end-modal", CoreComponents.show_modal("pdilemma-round-end-modal"))
  end

  defp hide_modal(socket) do
    socket
    |> push_js("pdilemma-round-end-modal", CoreComponents.hide_modal("pdilemma-round-end-modal"))
  end

end
