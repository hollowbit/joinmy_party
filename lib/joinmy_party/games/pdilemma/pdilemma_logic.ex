defmodule PdilemmaLogic do

  def toggle_selection(:cooperate), do: :defect
  def toggle_selection(:defect), do: :cooperate

  def calculate_score(:cooperate, :cooperate), do: 1
  def calculate_score(:defect, :defect), do: -1
  def calculate_score(:cooperate, :defect), do: -2
  def calculate_score(:defect, :cooperate), do: 2

end
