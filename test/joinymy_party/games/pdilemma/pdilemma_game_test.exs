defmodule PdilemmaGameTest do
  use ExUnit.Case
  import Mox

  doctest PdilemmaGame

  setup do
    JoinmyParty.TimerMock
    |> expect(:set_timer, fn _time, _pid -> %JoinmyParty.Timer{pid: nil, time_left_sec: 470} end)
    |> expect(:start_timer, fn timer -> %{timer | started: true} end)
    |> expect(:cancel_timer, fn timer -> %{timer | started: false} end)

    Phoenix.PubSub.subscribe(JoinmyParty.PubSub, "pdilemma:test_room")
    Phoenix.PubSub.subscribe(JoinmyParty.PubSub, "pdilemma:test_room:team_a")
    Phoenix.PubSub.subscribe(JoinmyParty.PubSub, "pdilemma:test_room:team_b")

    :ok
  end

  test "start game" do
    settings = %{
      room_id: "test_room",
      round_time_sec: 10,
      num_rounds: 3
    }

    {:ok, game_state} = PdilemmaGame.init(settings)
    assert %{room_id: "test_room", settings: %{round_time_sec: 10, num_rounds: 3}, started: false, round_timer: %{started: false}} = game_state

    # start the game
    {:noreply, game_state} = PdilemmaGame.handle_cast(:start_game, game_state)
    assert %{started: true, round_timer: %{started: true}} = game_state

    # test that the mocking works
    assert game_state.round_timer.time_left_sec == 470

    # nothing should happen when trying to start an already started game
    assert {:noreply, game_state} == PdilemmaGame.handle_cast(:start_game, game_state)
  end

  test "team toggle selection" do
    state = %{
      room_id: "test_room",
      team_a_selection: :defect,
      team_b_selection: :cooperate,
    }

    {:noreply, state} = PdilemmaGame.handle_cast({:team_toggle_selection, :team_a}, state)
    assert_receive({:team_selection_change, :cooperate})
    assert state.team_a_selection == :cooperate

    {:noreply, state} = PdilemmaGame.handle_cast({:team_toggle_selection, :team_b}, state)
    assert_receive({:team_selection_change, :defect})
    assert state.team_b_selection == :defect
  end

end
