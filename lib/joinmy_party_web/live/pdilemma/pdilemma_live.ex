defmodule JoinmyPartyWeb.PdilemmaWebLive do
  # In Phoenix v1.6+ apps, the line is typically:
  use JoinmyPartyWeb, :pdilemma_view

  @topic "pdilemma"

  def render(assigns = %{phase: :connecting}) do
    ~H"""
      <h1>Connecting...</h1>
    """
  end

  def render(assigns = %{phase: :lobbying, is_admin?: true}) do
    ~H"""
      <div class="v-card flex flex-col items-center">
        <h1 class="text-center text-xl">Prisoner's Dilemma</h1>
        <button phx-click="start_game" class="w-3/4 rounded-lg bg-emerald-400 text-slate-50 font-bold px-4 py-2 border-emerald-600 border-r-2 border-b-2 m-4">Start Game</button>
        <p class="text-center text-lg">You are on <span class="underline"><%= team_text(@team) %></span> 😎</p>
        <div class="flex flex-row mx-auto items-center">
          <p class="text-center text-lg"><span class="underline"><%= @total_players %></span> players waiting</p><span class="loading"></span>
        </div>
      </div>

    """
  end

  def render(assigns = %{phase: :lobbying, is_admin?: false}) do
    ~H"""
      <div class="v-card flex flex-col items-center">
        <h1 class="text-center text-xl">Prisoner's Dilemma</h1>
        <div class="flex flex-row mx-auto items-center">
            <p class="text-center text-lg">Waiting for the game to start</p><span class="loading"></span>
        </div>
        <p class="text-center text-lg">You are on <span class="underline"><%= team_text(@team) %></span> 😎</p>
      </div>
    """
  end

  def render(assigns = %{phase: :playing}) do
    ~H"""
      <header class="v-card">
        <h1 class="text-center text-xl">Round <%= @round %> of <%= @total_rounds %></h1>

        <h3 class="text-center">Round ends in <span class={if @round_time < 10, do: "text-red-500"}><%= @round_time %>s</span></h3>
      </header>

      <div class="flex flex-wrap">
        <PdilemmaWeb.SelectionComponent.selection_button selection={@selection} />
      </div>
      <div class="v-card">
        <h3 class="text-lg">Score Sheet 📝</h3>


        <table class="[&_th]:pr-2">
          <thead>
            <tr id="tally-header" phx-update="append">
              <th class="border-b-2 border-gray-400" id="round-header">Round</th>
              <%= for round <- 1..@round do %>
                <th class="px-2 border-b-2 border-gray-400" id={"round-#{round}"}><%= round %></th>
              <% end %>
            </tr>
          </thead>
          <tbody>
            <tr id="tally-team-a" phx-update="append">
              <td class={"px-2"  <> if @team == :team_a, do: " italic", else: ""} id="round-team-a">Team A : </td>
              <%= for {[team_a_score, _], round} <- Enum.reverse(@tally) |> Enum.with_index do %>
                <td class={"border-r-2 border-gray-400 px-2" <> if @team == :team_a, do: " italic", else: ""} id={"team-a-#{round}"}><%= team_a_score %></td>
              <% end %>
            </tr>
            <tr id="tally-team-b" phx-update="append">
              <td class={"px-2" <> if @team == :team_b, do: " italic", else: ""} id="round-team-b">Team B : </td>
              <%= for {[_, team_b_score], round} <- Enum.reverse(@tally) |> Enum.with_index do %>
                <td class={"border-r-2 border-gray-400 px-2" <> if @team == :team_b, do: " italic", else: ""} id={"team-b-#{round}"}><%= team_b_score %></td>
              <% end %>
            </tr>
          </tbody>
        </table>
        <p>You are on <span class="underline"><%= team_text(@team) %></span>.</p>
      </div>
    """
  end

  def render(assigns = %{phase: :end}) when assigns.winner == :tie do
    ~H"""
      <div class="v-card">
        <h1 class="text-center text-2xl">It's a Tie 😊</h1>
        <h3>Team A Score: <%= @team_a_score %></h3> <h3>Team B Score: <%= @team_b_score %></h3>
      </div>
    """
  end

  def render(assigns = %{phase: :end}) when assigns.winner == assigns.team do
    ~H"""
      <div class="v-card">
        <h1 class="text-center text-2xl">You Won! 🎉</h1>
        <h3>Team A Score: <%= @team_a_score %></h3> <h3>Team B Score: <%= @team_b_score %></h3>
      </div>
    """
  end

  def render(assigns = %{phase: :end}) when assigns.winner != assigns.team do
    ~H"""
      <div class="v-card">
        <h1 class="text-center text-2xl">You Lost 😞</h1>
        <h3>Team A Score: <%= @team_a_score %></h3> <h3>Team B Score: <%= @team_b_score %></h3>
      </div>
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
    num_rounds = 6
    game_pid = PdilemmaGame.get_room_pid_or_start(room_id, %{num_rounds: num_rounds, round_time_sec: 5 * 60})

    game_info = PdilemmaGame.pick_team(game_pid)
    state = %{
      is_admin?: game_info.is_admin?,
      phase: game_info.started && :playing || :lobbying,
      game_pid: game_pid,
      room_id: room_id,
      team: game_info.team,
      selection: game_info.selection,
      round: game_info.round,
      total_rounds: num_rounds,
      tally: game_info.tally,
      round_time: game_info.round_time,
      total_players: game_info.total_players
    }

    Phoenix.PubSub.subscribe(JoinmyParty.PubSub, @topic <> ":" <> room_id)
    Phoenix.PubSub.subscribe(JoinmyParty.PubSub, @topic <> ":" <> room_id <> ":" <> Atom.to_string(state.team))

    {:ok, assign(socket, state), temporary_assigns: [tally: []]}
  end

  def handle_event("change_selection", _params, socket = %{assigns: %{team: team, game_pid: game_pid}}) do
    PdilemmaGame.team_toggle_selection(team, game_pid)
    {:noreply, socket}
  end

  def handle_event("start_game", _params, socket = %{assigns: %{game_pid: game_pid}}) do
    PdilemmaGame.start_game(game_pid)
    {:noreply, socket}
  end

  def handle_info({:players_joined, players}, socket), do: {:noreply, assign(socket, :total_players, players)}

  def handle_info({:game_start, time}, socket) do
    new_state = %{
      phase: :playing,
      round_time: time
    }
    {:noreply, assign(socket, new_state)}
  end

  def handle_info({:round_timer, time}, socket), do: {:noreply, assign(socket, :round_time, time)}

  def handle_info({:round_end, round_results}, socket) do
    new_state = %{
      round: round_results.next_round,
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

  def handle_info({:team_selection_change, selection}, socket), do:
    {:noreply, assign(socket, :selection, selection)}

end
