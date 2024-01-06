defmodule PdilemmaGame do
  use GenServer

  @default_round_time_sec 300

  @impl true
  def init(room_id) do
    init_state = %{
      room_id: room_id,
      round: 1,
      team_a_selection: :cooperate,
      team_b_selection: :cooperate,
      team_a_score: 0,
      team_b_score: 0,
      round_timer: Timer.set_timer(@default_round_time_sec, self())
    }

    {:ok, init_state}
  end

  @impl true
  def handle_cast(:team_a_toggle_selection, state) do
    new_selection = PdilemmaLogic.toggle_selection(state.team_a_selection)
    new_state = Map.put(state, :team_a_selection, new_selection)
    {:ok, new_state}
  end

  @impl true
  def handle_cast(:team_b_toggle_selection, state) do
    new_selection = PdilemmaLogic.toggle_selection(state.team_b_selection)
    new_state = Map.put(state, :team_b_selection, new_selection)
    {:ok, new_state}
  end

  @impl true
  def handle_call(:team_a_info, _from, state) do
    %{
      selection: state.team_a_selection,
      score: state.team_a_score
    }
  end

  @impl true
  def handle_call(:team_b_info, _from, state) do
    %{
      selection: state.team_a_selection,
      score: state.team_a_score
    }
  end

  @impl true
  def handle_info({:update_time, 0}, state) do
    new_state = Map.merge(state, %{
      round: state.round + 1,
      team_a_selection: :cooperate,
      team_b_selection: :cooperate,
      team_a_score: state.team_a_score + PdilemmaLogic.calculate_score(state.team_a_selection, state.team_b_selection),
      team_b_score: state.team_b_score + PdilemmaLogic.calculate_score(state.team_b_selection, state.team_a_selection),
      round_timer: Timer.set_timer(@default_round_time_sec, self())
    })
    {:noreply, new_state}
  end

  # decrease timer until time is 0
  @impl true
  def handle_info({:update_time, time_left}, state) do
    new_state = Map.put(state, :round_timer, Timer.set_timer(time_left, self()))
    {:noreply, new_state}
  end

  # Helper Functions

  def team_a_toggle_selection(pid) do
    GenServer.cast(pid, :team_a_toggle_selection)
  end

  def team_b_toggle_selection(pid) do
    GenServer.cast(pid, :team_b_toggle_selection)
  end

  def team_a_info(pid) do
    GenServer.call(pid, :team_a_info)
  end

  def team_b_info(pid) do
    GenServer.call(pid, :team_b_info)
  end

end
