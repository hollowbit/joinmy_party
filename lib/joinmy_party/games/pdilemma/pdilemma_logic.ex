defmodule PdilemmaLogic do

  def toggle_selection(:cooperate), do: :defect
  def toggle_selection(:defect), do: :cooperate

  def calculate_score(:cooperate, :cooperate), do: 1
  def calculate_score(:defect, :defect), do: -1
  def calculate_score(:cooperate, :defect), do: -2
  def calculate_score(:defect, :cooperate), do: 2

  def get_winner(team_a_score, team_b_score) when team_a_score > team_b_score, do: :team_a
  def get_winner(team_a_score, team_b_score) when team_b_score > team_a_score, do: :team_b
  def get_winner(_team_a_score, _team_b_score), do: :tie

end
