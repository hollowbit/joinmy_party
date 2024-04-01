defmodule PdilemmaGame do
  use GenServer, shutdown: 5_000

  def start_link(settings) do
    GenServer.start_link(__MODULE__, settings, name: {:global, "party:" <> settings.room_id})
  end

  @impl true
  def init(%{room_id: room_id, round_time_sec: round_time_sec, num_rounds: num_rounds}) do
    init_state = %{
      room_id: room_id,
      settings: %{round_time_sec: round_time_sec, num_rounds: num_rounds},
      started: false,
      round: 1,
      team_a_selection: :cooperate,
      team_b_selection: :cooperate,
      tally: [],
      team_a_num_players: 0,
      team_b_num_players: 0,
      round_timer: JoinmyParty.Timer.set_timer(round_time_sec, self())
    }

    {:ok, init_state}
  end

  @impl true
  def handle_cast(:start_game, state = %{round_timer: %{started: false}}) do
    broadcast_game_start(state.room_id, state.settings.round_time_sec)
    new_state = Map.merge(state, %{
      started: true,
      round_timer: state.round_timer |> JoinmyParty.Timer.start_timer
    })
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:team_toggle_selection, :team_a}, state) do
    new_selection = PdilemmaLogic.toggle_selection(state.team_a_selection)
    broadcast_team_selection_change(state.room_id, :team_a, new_selection)
    {:noreply, Map.put(state, :team_a_selection, new_selection)}
  end

  @impl true
  def handle_cast({:team_toggle_selection, :team_b}, state) do
    new_selection = PdilemmaLogic.toggle_selection(state.team_b_selection)
    broadcast_team_selection_change(state.room_id, :team_b, new_selection)
    {:noreply, Map.put(state, :team_b_selection, new_selection)}
  end

  def handle_cast({:player_leave, :team_a}, state = %{team_a_num_players: team_a_num_players}) do
    players_team = team_a_num_players - 1
    if players_team < 1 do
      {:stop, {:shutdown, "Admin player left"}, state}
    else
      broadcast_player_count_change(state.room_id, players_team + state.team_b_num_players)
      {:noreply, Map.put(state, :team_a_num_players, players_team)}
    end
  end

  def handle_cast({:player_leave, :team_b}, state = %{team_b_num_players: team_b_num_players}) do
    players_team = team_b_num_players - 1
    if players_team < 1 and state.started do
      {:stop, {:shutdown, "All team B players left"}, state}
    else
      broadcast_player_count_change(state.room_id, players_team + state.team_a_num_players)
      {:noreply, Map.put(state, :team_b_num_players, players_team)}
    end
  end

  @impl true
  def terminate(reason, state) do
    # if not a :normal exit, close all live sockets with a reason
    case reason do
      {:shutdown, message} -> broadcast_party_closed(state.room_id, message)
      :shutdown -> broadcast_party_closed(state.room_id, "Unknown error")
      _ -> :ok
    end

    {:shutdown, reason, state}
  end

  @impl true
  def handle_call(:pick_team, _from, state = %{team_a_num_players: players}) when state.team_a_num_players <= state.team_b_num_players do
    total_players = state.team_a_num_players + state.team_b_num_players + 1
    team_info = %{
      # set first player to admin
      is_admin?: state.team_a_num_players == 0 && state.team_b_num_players == 0,
      team: :team_a,
      started: state.started,
      selection: state.team_a_selection,
      tally: state.tally,
      round: state.round,
      round_time: state.round_timer.time_left_sec,
      total_players: total_players
    }

    broadcast_player_count_change(state.room_id, total_players)
    {:reply, team_info, Map.put(state, :team_a_num_players, players + 1)}
  end

  @impl true
  def handle_call(:pick_team, _from, state = %{team_b_num_players: players}) when state.team_a_num_players > state.team_b_num_players do
    total_players = state.team_a_num_players + state.team_b_num_players + 1
    team_info = %{
      is_admin?: false,
      team: :team_b,
      started: state.started,
      selection: state.team_b_selection,
      tally: state.tally,
      round: state.round,
      round_time: state.round_timer.time_left_sec,
      total_players: total_players
    }

    broadcast_player_count_change(state.room_id, total_players)
    {:reply, team_info, Map.put(state, :team_b_num_players, players + 1)}
  end

  # game end
  @impl true
  def handle_info({:update_time, %{time_left_sec: 0}}, state) when state.round == state.settings.num_rounds do
    # get scores
    team_a_score = PdilemmaLogic.get_team_total_score(:team_a, state.tally)
    team_b_score = PdilemmaLogic.get_team_total_score(:team_b, state.tally)
    team_a_points_earned = PdilemmaLogic.calculate_score(state.team_a_selection, state.team_b_selection)
    team_b_points_earned = PdilemmaLogic.calculate_score(state.team_b_selection, state.team_a_selection)
    team_a_final_score = team_a_score + team_a_points_earned
    team_b_final_score = team_b_score + team_b_points_earned

    tally = [[
      team_a_final_score,
      team_b_final_score
      ]] ++ state.tally

    winner = PdilemmaLogic.get_winner(team_a_final_score, team_b_final_score)

    # create results to broadcast back to players
    game_end_results = %{
      winner: winner,
      team_a_score: team_a_score,
      team_b_score: team_b_score,
      team_a_points_earned: team_a_points_earned,
      team_b_points_earned: team_b_points_earned,
      team_a_selection: state.team_a_selection,
      team_b_selection: state.team_b_selection,
      tally: tally
    }
    broadcast_game_end(state.room_id, game_end_results)

    :global.unregister_name(state.room_id)
    {:stop, :normal, state}
  end

  # round end
  @impl true
  def handle_info({:update_time, %{time_left_sec: 0}}, state) do
    # get scores
    team_a_score = PdilemmaLogic.get_team_total_score(:team_a, state.tally)
    team_b_score = PdilemmaLogic.get_team_total_score(:team_b, state.tally)
    team_a_points_earned = PdilemmaLogic.calculate_score(state.team_a_selection, state.team_b_selection)
    team_b_points_earned = PdilemmaLogic.calculate_score(state.team_b_selection, state.team_a_selection)

    tally = [[
      team_a_score + team_a_points_earned,
      team_b_score + team_b_points_earned
      ]] ++ state.tally

    # create results to broadcast back to players
    round_end_results = %{
      team_a_score: team_a_score,
      team_b_score: team_b_score,
      team_a_selection: state.team_a_selection,
      team_b_selection: state.team_b_selection,
      team_a_points_earned: team_a_points_earned,
      team_b_points_earned: team_b_points_earned,
      round: state.round,
      next_round: state.round + 1,
      tally: tally
    }
    broadcast_round_end(state.room_id, round_end_results)
    broadcast_round_timer(state.room_id, state.settings.round_time_sec)

    # reset selections
    broadcast_team_selection_change(state.room_id, :team_a, :cooperate)
    broadcast_team_selection_change(state.room_id, :team_b, :cooperate)

    new_state = Map.merge(state, %{
      round: state.round + 1,
      team_a_selection: :cooperate,
      team_b_selection: :cooperate,
      round_timer: JoinmyParty.Timer.set_timer(state.settings.round_time_sec, self()) |> JoinmyParty.Timer.start_timer(),
      tally: tally
    })
    {:noreply, new_state}
  end

  # decrease timer until time is 0
  @impl true
  def handle_info({:update_time, timer}, state) do
    broadcast_round_timer(state.room_id, timer.time_left_sec)

    new_state = Map.put(state, :round_timer, timer |> JoinmyParty.Timer.start_timer())
    {:noreply, new_state}
  end

  # Helper Functions

  def get_room_pid_or_start(room_id, settings) do
    game_pid = case :global.whereis_name("party:" <> String.downcase(room_id)) do
      :undefined ->
        # use a supervisor to avoid having the admin liveview socket supervise and close the game prematurely
        children = [
          %{
            id: "party:" <> String.downcase(room_id),
            start: {PdilemmaGame, :start_link, [Map.merge(%{room_id: String.downcase(room_id)}, settings)]},
          }
        ]
        {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)
        [{_id, game_pid, _type, _modules}] = Supervisor.which_children(pid)
        :global.register_name("party:" <> String.downcase(room_id), game_pid)
        game_pid
      pid -> pid
    end

    game_pid
  end

  @spec start_game(pid()) :: :ok
  def start_game(pid), do: GenServer.cast(pid, :start_game)

  @spec team_toggle_selection(team :: :team_a | :team_b, pid()) :: :ok
  def team_toggle_selection(team, pid), do: GenServer.cast(pid, {:team_toggle_selection, team})

  def pick_team(pid), do: GenServer.call(pid, :pick_team)

  @spec player_leave(:team_a | :team_b, pid()) :: :ok
  def player_leave(team, pid), do: GenServer.cast(pid, {:player_leave, team})

  # Broadcast Helpers

  defp broadcast_game_start(room_id, timer_sec), do:
    Phoenix.PubSub.broadcast(JoinmyParty.PubSub, "pdilemma:" <> room_id, {:game_start, timer_sec})

  defp broadcast_player_count_change(room_id, players), do:
    Phoenix.PubSub.broadcast(JoinmyParty.PubSub, "pdilemma:" <> room_id, {:player_count_change, players})

  defp broadcast_round_timer(room_id, timer_sec), do:
    Phoenix.PubSub.broadcast(JoinmyParty.PubSub, "pdilemma:" <> room_id, {:round_timer, timer_sec})

  defp broadcast_round_end(rood_id, round_end_results), do:
    Phoenix.PubSub.broadcast(JoinmyParty.PubSub, "pdilemma:" <> rood_id, {:round_end, round_end_results})

  @spec broadcast_team_selection_change(room_id :: String.t(), team :: :team_a | :team_b, selection :: :cooperate | :defect) :: any
  defp broadcast_team_selection_change(room_id, team, selection), do:
    Phoenix.PubSub.broadcast(JoinmyParty.PubSub, "pdilemma:" <> room_id <> ":" <> Atom.to_string(team), {:team_selection_change, selection})

  defp broadcast_game_end(room_id, game_end_results), do:
    Phoenix.PubSub.broadcast(JoinmyParty.PubSub, "pdilemma:" <> room_id, {:game_end, game_end_results})

  defp broadcast_party_closed(room_id, reason), do:
    Phoenix.PubSub.broadcast(JoinmyParty.PubSub, "pdilemma:" <> room_id, {:party_closed, reason})

end
