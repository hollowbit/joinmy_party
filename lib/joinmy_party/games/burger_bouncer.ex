# This is some kind of Mastermind game using burgers. Keeping the code here for now.
defmodule BurgerBouncer do
  use GenServer

  @impl true
  def init({timer_sec}) do
    {:ok, %{recipe: generate_recipe(), time: timer_sec}}


  end

  @impl true
  def handle_cast( {:make_guess, {player, guess} }, state = %{recipe: recipe}) do

    {:ok, {}}
  end

  # Private Functions
  @spec generate_recipe :: list
  def generate_recipe() do
    for _ <- 1..4, do: get_ingredient()
  end

  @spec generate_recipe :: atom
  defp get_ingredient() do
    Enum.random [
      :pickles,
      :ketchup,
      :mayo,
      :tomato,
      :patty,
      :lettuce,
      :mustard,
      :cheese
    ]
  end

  def compare_guesses(recipe, guess) do
    correct_ingr = compare_ingr(0, recipe, guess)

    correct_pos = compare_guess_pos(0, recipe, guess)

    {correct_ingr, correct_pos}
  end

  defp compare_ingr(acc, recipe, [guess_head | guess_tail]) do
    new_acc = if Enum.member?(recipe, guess_head) do
      acc + 1
    else
      acc
    end
    compare_ingr(new_acc, recipe, guess_tail)
  end

  defp compare_ingr(acc, _recipe, []) do
    acc
  end

  defp compare_guess_pos(acc, [recipe_head | recipe_tail], [guess_head | guess_tail]) do
    new_acc = if recipe_head == guess_head do
      acc + 1
    else
      acc
    end

    compare_guess_pos(new_acc, recipe_tail, guess_tail)
  end

  defp compare_guess_pos(acc, [], []) do
    acc
  end

end
