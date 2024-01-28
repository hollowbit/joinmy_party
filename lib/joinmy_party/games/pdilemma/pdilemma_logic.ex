defmodule PdilemmaLogic do

  @spec toggle_selection(:cooperate | :defect) :: :cooperate | :defect
  def toggle_selection(:cooperate), do: :defect
  def toggle_selection(:defect), do: :cooperate

  @spec calculate_score(:cooperate | :defect, :cooperate | :defect) :: -10 | -5 | 5 | 10
  def calculate_score(:cooperate, :cooperate), do: 5
  def calculate_score(:defect, :defect), do: -5
  def calculate_score(:cooperate, :defect), do: -10
  def calculate_score(:defect, :cooperate), do: 10

  @spec get_winner(any(), any()) :: :team_a | :team_b | :tie
  def get_winner(team_a_score, team_b_score) when team_a_score > team_b_score, do: :team_a
  def get_winner(team_a_score, team_b_score) when team_b_score > team_a_score, do: :team_b
  def get_winner(_team_a_score, _team_b_score), do: :tie

  @spec get_team_total_score(:team_a | :team_b, [...]) :: integer()
  def get_team_total_score(:team_a, []), do: 0
  def get_team_total_score(:team_b, []), do: 0
  def get_team_total_score(:team_a, [[team_score, _] | _]), do: team_score
  def get_team_total_score(:team_b, [[_, team_score] | _]), do: team_score

end
