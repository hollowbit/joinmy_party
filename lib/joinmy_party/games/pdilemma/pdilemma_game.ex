defmodule PdilemmaGame do
  use GenServer

  @round_time_sec 300
  @num_rounds 6

  @impl true
  def init(room_id) do
    init_state = %{
      room_id: room_id,
      round: 1,
      team_a_selection: :cooperate,
      team_b_selection: :cooperate,
      team_a_score: 0,
      team_b_score: 0,
      team_a_num_players: 0,
      team_b_num_players: 0,
      round_timer: JoinmyParty.Timer.set_timer(@round_time_sec, self())
    }

    {:ok, init_state}
  end

  @impl true
  def handle_cast(:team_a_toggle_selection, state) do
    new_selection = PdilemmaLogic.toggle_selection(state.team_a_selection)
    broadcast_team_a_selection_change(state.room_id, new_selection)

    new_state = Map.put(state, :team_a_selection, new_selection)
    {:noreply, new_state}
  end

  @impl true
  def handle_cast(:team_b_toggle_selection, state) do
    new_selection = PdilemmaLogic.toggle_selection(state.team_b_selection)
    broadcast_team_b_selection_change(state.room_id, new_selection)

    new_state = Map.put(state, :team_b_selection, new_selection)
    {:noreply, new_state}
  end

  @impl true
  def handle_call(:pick_team, _from, state = %{team_a_num_players: players}) when state.team_a_num_players > state.team_b_num_players do
    team_info = %{
      team: :team_b,
      selection: state.team_b_selection,
      score: state.team_b_score,
      round: state.round,
      round_time: state.round_timer.time_left_sec
    }
    {:reply, team_info, Map.put(state, :team_b_num_players, players + 1)}
  end

  @impl true
  def handle_call(:pick_team, _from, state = %{team_b_num_players: players}) when state.team_b_num_players >= state.team_a_num_players do
    team_info = %{
      team: :team_a,
      selection: state.team_a_selection,
      score: state.team_a_score,
      round: state.round,
      round_time: state.round_timer.time_left_sec
    }
    {:reply, team_info, Map.put(state, :team_a_num_players, players + 1)}
  end

  # game end
  @impl true
  def handle_info({:update_time, 0}, state = %{round: @num_rounds}) do
    # get scores
    team_a_points_earned = PdilemmaLogic.calculate_score(state.team_a_selection, state.team_b_selection)
    team_b_points_earned = PdilemmaLogic.calculate_score(state.team_b_selection, state.team_a_selection)

    # create results to broadcast back to players
    game_end_results = %{
      team_a_score: state.team_a_score,
      team_b_score: state.team_b_score,
      team_a_selection: state.team_a_selection,
      team_b_selection: state.team_b_selection,
      team_a_points_earned: team_a_points_earned,
      team_b_points_earned: team_b_points_earned,
    }
    broadcast_game_end(state.room_id, game_end_results)

    :global.unregister_name(state.room_id)

    new_state = Map.merge(state, %{
      team_a_score: state.team_a_score + team_a_points_earned,
      team_b_score: state.team_b_score + team_b_points_earned
    })
    {:stop, :normal, new_state}
  end

  # round end
  @impl true
  def handle_info({:update_time, 0}, state) do
    # get scores
    team_a_points_earned = PdilemmaLogic.calculate_score(state.team_a_selection, state.team_b_selection)
    team_b_points_earned = PdilemmaLogic.calculate_score(state.team_b_selection, state.team_a_selection)

    # create results to broadcast back to players
    round_end_results = %{
      team_a_score: state.team_a_score,
      team_b_score: state.team_b_score,
      team_a_selection: state.team_a_selection,
      team_b_selection: state.team_b_selection,
      team_a_points_earned: team_a_points_earned,
      team_b_points_earned: team_b_points_earned,
      round: state.round,
      next_round: state.round + 1,
    }
    broadcast_round_end(state.room_id, round_end_results)

    new_state = Map.merge(state, %{
      round: state.round + 1,
      team_a_selection: :cooperate,
      team_b_selection: :cooperate,
      team_a_score: state.team_a_score + team_a_points_earned,
      team_b_score: state.team_b_score + team_b_points_earned,
      round_timer: JoinmyParty.Timer.set_timer(@round_time_sec, self())
    })
    {:noreply, new_state}
  end

  # decrease timer until time is 0
  @impl true
  def handle_info({:update_time, time_left}, state) do
    broadcast_round_timer(state.room_id, time_left)

    new_state = Map.put(state, :round_timer, JoinmyParty.Timer.set_timer(time_left, self()))
    {:noreply, new_state}
  end

  # Helper Functions

  def get_room_pid(room_id) do
    game_pid = case :global.whereis_name(room_id) do
      :undefined ->
        {:ok, pid} = GenServer.start_link(__MODULE__, room_id)
        :global.register_name(room_id, pid)
        pid
      pid -> pid
    end

    game_pid
  end

  def team_a_toggle_selection(pid) do
    GenServer.cast(pid, :team_a_toggle_selection)
  end

  def team_b_toggle_selection(pid) do
    GenServer.cast(pid, :team_b_toggle_selection)
  end

  def pick_team(pid) do
    GenServer.call(pid, :pick_team)
  end

  defp broadcast_round_timer(room_id, timer_sec) do
    Phoenix.PubSub.broadcast(JoinmyParty.PubSub, "pdilemma:" <> room_id, {:round_timer, timer_sec})
  end

  defp broadcast_round_end(rood_id, round_end_results) do
    Phoenix.PubSub.broadcast(JoinmyParty.PubSub, "pdilemma:" <> rood_id, {:round_end, round_end_results})
  end

  defp broadcast_team_a_selection_change(room_id, selection) do
    Phoenix.PubSub.broadcast(JoinmyParty.PubSub, "pdilemma:" <> room_id, {:team_a_selection_change, selection})
  end

  defp broadcast_team_b_selection_change(room_id, selection) do
    Phoenix.PubSub.broadcast(JoinmyParty.PubSub, "pdilemma:" <> room_id, {:team_b_selection_change, selection})
  end

  defp broadcast_game_end(room_id, game_end_results) do
    Phoenix.PubSub.broadcast(JoinmyParty.PubSub, "pdilemma:" <> room_id, {:game_end, game_end_results})
  end

end
