defmodule JoinmyPartyWeb.PdilemmaLive do
  # In Phoenix v1.6+ apps, the line is typically: use MyAppWeb, :live_view
  use Phoenix.LiveView

  @topic "pdilemma"

  def render(assigns) do
    ~H"""
    <%= case @phase do %>
    <% :connecting -> %>
      <h1>Connecting...</h1>
    <% :playing -> %>

      <button phx-click="change_selection">
        <%= case @selection do
          :defect -> "Defect"
          :cooperate -> "Cooperate"
          end %>
          <small>(click to change)</small>
      </button>

      <h3>Score: <%= @score %></h3>
      <h3>Round: <%= @round %></h3>
      <h3>Team: <%= @team %></h3>
      <h3>Round Time: <%= @round_time %></h3>

    <% :end -> %>
      <h1>Game Over</h1>
      <h3>Winner: <%= @winner %></h3>
      <h3>Team A Score: <%= @team_a_score %></h3> <h3>Team B Score: <%= @team_b_score %></h3>

    <% end %>
    """
  end

  def mount(params, session, socket) do
    if connected?(socket) do
      connected_mount(params, session, socket)
    else
      {:ok, assign(socket, :phase, :connecting)}
    end
  end

  defp connected_mount(%{"room_id" => room_id}, _session, socket) do
    game_pid = PdilemmaGame.get_room_pid(room_id)

    IO.inspect(socket.assigns)

    game_info = PdilemmaGame.pick_team(game_pid)
    state = %{
      phase: :playing,
      game_pid: game_pid,
      room_id: room_id,
      team: game_info.team,
      selection: game_info.selection,
      score: game_info.score,
      round_time: game_info.round_time,
      round: game_info.round,
    }

    IO.inspect(state)
    Phoenix.PubSub.subscribe(JoinmyParty.PubSub, @topic <> ":" <> room_id)

    {:ok, assign(socket, state)}
  end

  def handle_event("change_selection", _params, socket = %{assigns: %{team: :team_a, game_pid: game_pid}}) do
    PdilemmaGame.team_a_toggle_selection(game_pid)
    {:noreply, socket}
  end

  def handle_event("change_selection", _params, socket = %{assigns: %{team: :team_b, game_pid: game_pid}}) do
    PdilemmaGame.team_b_toggle_selection(game_pid)
    {:noreply, socket}
  end

  def handle_info({:round_timer, time}, socket), do: {:noreply, assign(socket, :round_time, time)}

  def handle_info({:round_end, round_results}, socket), do: {:noreply, assign(socket, :round, round_results.next_round)}

  def handle_info({:game_end, game_results}, socket) do
    new_state = %{
      phase: :end,
      team_a_score: game_results.team_a_score + game_results.team_a_points_earned,
      team_b_score: game_results.team_b_score + game_results.team_b_points_earned,
      winner: game_results.winner
    }
    {:noreply, assign(socket, new_state)}
  end

  def handle_info({:team_a_selection_change, selection}, socket) when socket.assigns.team == :team_a, do:
    {:noreply, assign(socket, :selection, selection)}
  def handle_info({:team_a_selection_change, _}, socket), do: {:noreply, socket}

  def handle_info({:team_b_selection_change, selection}, socket) when socket.assigns.team == :team_b, do:
    {:noreply, assign(socket, :selection, selection)}
  def handle_info({:team_b_selection_change, _}, socket), do: {:noreply, socket}

end
