defmodule PdilemmaLogicTest do
  use ExUnit.Case
  doctest PdilemmaLogic

  test "get team total score" do
    tally_1 = []
    assert PdilemmaLogic.get_team_total_score(:team_a, tally_1) == 0
    assert PdilemmaLogic.get_team_total_score(:team_b, tally_1) == 0

    tally_2 = [[3, 0]] ++ tally_1
    assert PdilemmaLogic.get_team_total_score(:team_a, tally_2) == 3
    assert PdilemmaLogic.get_team_total_score(:team_b, tally_2) == 0

    tally_3 = [[10, 5]] ++ tally_2
    assert PdilemmaLogic.get_team_total_score(:team_a, tally_3) == 10
    assert PdilemmaLogic.get_team_total_score(:team_b, tally_3) == 5
  end

end
