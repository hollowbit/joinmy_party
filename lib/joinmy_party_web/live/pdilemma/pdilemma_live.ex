defmodule JoinmyPartyWeb.PdilemmaWebLive do
  # In Phoenix v1.6+ apps, the line is typically:
  use JoinmyPartyWeb, :pdilemma_view

  @topic "pdilemma"

  def render(assigns = %{phase: :connecting}) do
    ~H"""
      <h1>Connecting...</h1>
    """
  end

  def render(assigns = %{phase: :playing}) do
    ~H"""
      <header class="v-card">
        <h1 class="text-center text-xl">Round <%= @round %></h1>

        <h3 class="text-center">Round ends in <span class={if @round_time < 10, do: "text-red-500"}><%= @round_time %>s</span></h3>
      </header>

      <div class="flex flex-wrap">
        <PdilemmaWeb.SelectionComponent.selection_button selection={@selection} />
      </div>
      <div class="v-card">
        <h3 class="text-lg">Score Sheet 📝</h3>


        <table class="[&_th]:pr-2">
          <thead>
            <tr>
              <th class="border-b-2 border-gray-400">Round</th>
              <%= for round <- 1..@round do %>
                <th class="px-2 border-b-2 border-gray-400"><%= round %></th>
              <% end %>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td class={"px-2"  <> if @team == :team_a, do: " italic", else: ""}>Team A : </td>
              <%= for [team_a_score, _] <- @tally do %>
                <td class={"border-r-2 border-gray-400 px-2" <> if @team == :team_a, do: " italic", else: ""}><%= team_a_score %></td>
              <% end %>
            </tr>
            <tr>
              <td class={"px-2" <> if @team == :team_b, do: " italic", else: ""}>Team B : </td>
              <%= for [_, team_b_score] <- @tally do %>
                <td class={"border-r-2 border-gray-400 px-2" <> if @team == :team_b, do: " italic", else: ""}><%= team_b_score %></td>
              <% end %>
            </tr>
          </tbody>
        </table>
        <p>You are on <%= team_text(@team) %>.</p>
      </div>
    """
  end

  def render(assigns = %{phase: :end}) do
    ~H"""
      <h1>Game Over</h1>
      <h3>Winner: <%= team_text(@winner) %></h3>
      <h3>Team A Score: <%= @team_a_score %></h3> <h3>Team B Score: <%= @team_b_score %></h3>
    """
  end

  # UI Helpers

  defp team_text(:team_a), do: "Team A"
  defp team_text(:team_b), do: "Team B"
  defp team_text(:tie), do: "Tie"

  # Logic

  def mount(params, session, socket) do
    if connected?(socket) do
      connected_mount(params, session, socket)
    else
      {:ok, assign(socket, :phase, :connecting)}
    end
  end

  defp connected_mount(%{"room_id" => room_id}, _session, socket) do
    game_pid = PdilemmaGame.get_room_pid_or_start(room_id, %{num_rounds: 3, round_time_sec: 20})

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
      tally: game_info.tally
    }

    Phoenix.PubSub.subscribe(JoinmyParty.PubSub, @topic <> ":" <> room_id)

    {:ok, assign(socket, state)}
  end

  def handle_event("change_selection", _params, socket = %{assigns: %{team: team, game_pid: game_pid}}) do
    case team do
      :team_a -> PdilemmaGame.team_a_toggle_selection(game_pid)
      :team_b -> PdilemmaGame.team_b_toggle_selection(game_pid)
    end
    {:noreply, socket}
  end

  def handle_info({:round_timer, time}, socket), do: {:noreply, assign(socket, :round_time, time)}

  def handle_info({:round_end, round_results}, socket) do
    new_state = %{
      round: round_results.next_round,
      score: case socket.assigns.team do
          :team_a -> round_results.team_a_score + round_results.team_a_points_earned
          :team_b -> round_results.team_b_score + round_results.team_b_points_earned
        end,
      tally: round_results.tally
    }
    {:noreply, assign(socket, new_state)}
  end

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
  def handle_info({:team_b_selection_change, selection}, socket) when socket.assigns.team == :team_b, do:
    {:noreply, assign(socket, :selection, selection)}

end
