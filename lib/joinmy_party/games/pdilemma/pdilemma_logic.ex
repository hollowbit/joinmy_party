defmodule PdilemmaLogic do

  def toggle_selection(:cooperate) do
    :defect
  end

  def toggle_selection(:defect) do
    :cooperate
  end

  def calculate_score(:cooperate, :cooperate) do
    1
  end

  def calculate_score(:defect, :defect) do
    -1
  end

  def calculate_score(:cooperate, :defect) do
    -2
  end

  def calculate_score(:defect, :cooperate) do
    2
  end

end
