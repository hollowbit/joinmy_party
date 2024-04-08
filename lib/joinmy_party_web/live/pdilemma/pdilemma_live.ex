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
        <button phx-click="start_game" disabled={@total_players < 2} class={"w-3/4 rounded-lg text-slate-50 font-bold px-4 py-2 border-r-2 border-b-2 m-4 " <> if @total_players < 2, do: "bg-slate-400 border-slate-600 cursor-default", else: "bg-emerald-400 border-emerald-600"}>Start Game</button>
        <%= if @total_players < 2 do %>
            <p class="text-center text-sm italic text-slate-600">Waiting for at least 2 players to start</p>
          <% end %>
        <p class="text-center text-lg">You are on <span class="underline"><%= team_text(@team) %></span> 😎</p>
        <div class="flex flex-row mx-auto items-center">
          <p class="text-center text-lg"><span class="underline"><%= @total_players %></span> player<%= if @total_players > 1, do: "s", else: "" %> waiting</p><span class="loading"></span>
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

        <h3 class="text-center">Round ends in <span class={if @round_time < 10, do: "text-red-500"}><%= seconds_to_time(@round_time) %></span></h3>
      </header>

      <.live_component module={PdilemmaWeb.RoundEndModal} id="round-end-modal" />

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
              <td class={"px-2"  <> if @team == :team_a, do: " italic", else: ""} id="round-team-a">Team A</td>
              <%= for {[team_a_score, _], round} <- Enum.reverse(@tally) |> Enum.with_index do %>
                <td class={"border-r-2 border-gray-400 px-2" <> if @team == :team_a, do: " italic", else: ""} id={"team-a-#{round}"}><%= team_a_score %></td>
              <% end %>
            </tr>
            <tr id="tally-team-b" phx-update="append">
              <td class={"px-2" <> if @team == :team_b, do: " italic", else: ""} id="round-team-b">Team B</td>
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

  defp seconds_to_time(seconds) do
    minutes = div(seconds, 60)
    remaining_seconds = rem(seconds, 60)

    case minutes do
      0 -> "#{remaining_seconds}s"
      _ -> "#{minutes}:#{String.pad_leading(Integer.to_string(remaining_seconds), 2, "0")}s"
    end
  end

  # Lifecycle Functions
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
      last_round_selection: :defect,
      other_team_selection: :defect,
      last_round_points_earned: 0,
      round: game_info.round,
      total_rounds: num_rounds,
      tally: game_info.tally,
      round_time: game_info.round_time,
      total_players: game_info.total_players,
      page_title: "Prisoner's Dilemma",
    }

    Phoenix.PubSub.subscribe(JoinmyParty.PubSub, @topic <> ":" <> String.downcase(room_id))
    Phoenix.PubSub.subscribe(JoinmyParty.PubSub, @topic <> ":" <> String.downcase(room_id) <> ":" <> Atom.to_string(state.team))

    {:ok, assign(socket, state), temporary_assigns: [tally: []]}
  end

  def terminate(reason, socket = %{assigns: %{game_pid: game_pid, team: team}}) do
    PdilemmaGame.player_leave(team, game_pid)
    {:shutdown, reason, socket}
  end

  # Event Handlers
  def handle_event("change_selection", _params, socket = %{assigns: %{team: team, game_pid: game_pid}}) do
    PdilemmaGame.team_toggle_selection(team, game_pid)
    {:noreply, socket}
  end

  def handle_event("start_game", _params, socket = %{assigns: %{game_pid: game_pid}}) do
    PdilemmaGame.start_game(game_pid)
    {:noreply, socket}
  end

  def handle_info({:player_count_change, players}, socket), do: {:noreply, assign(socket, :total_players, players)}

  def handle_info({:game_start, time}, socket) do
    new_state = %{
      phase: :playing,
      round_time: time
    }
    {:noreply, assign(socket, new_state)}
  end

  def handle_info({:round_timer, time}, socket), do: {:noreply, assign(socket, :round_time, time)}

  def handle_info({:round_end, round_results}, socket) do
    {last_round_selection, other_team_selection, last_round_points_earned} =
      case socket.assigns.team do
        :team_a -> {round_results.team_a_selection, round_results.team_b_selection, round_results.team_a_points_earned}
        :team_b -> {round_results.team_b_selection, round_results.team_a_selection, round_results.team_b_points_earned}
      end


    new_state = %{
      round: round_results.next_round,
      tally: round_results.tally,
    }

    round_results = %{
      id: "round-end-modal",
      open: true,
      last_round_selection: last_round_selection,
      other_team_selection: other_team_selection,
      last_round_points_earned: last_round_points_earned,
      round: round_results.next_round
    }

    send_update(PdilemmaWeb.RoundEndModal, round_results)
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

  def handle_info({:party_closed, reason}, socket) do
    {:noreply, push_navigate(socket, to: "/") |> put_flash(:error, "Party closed: #{reason}")}
  end

end
