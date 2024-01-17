defmodule PdilemmaWeb.SelectionComponent do
  use Phoenix.Component

  def selection_button(assigns) do
    ~H"""
    <button phx-click="change_selection"
      class={"flex-1 my-3 max-w-sm mx-auto shadow-slate-400 shadow-md rounded-2xl px-4 aspect-square text-gray-100 font-bold text-3xl " <> if @selection == :cooperate do "border-green-700 bg-green-500" else "border-red-700 bg-red-500" end}
    >
      <%= selection_text(@selection) %>
      <br />
      <small class="italic text-sm">(click to <%= selection_opposite_text(@selection) %>)</small>
    </button>
    """
  end

  defp selection_opposite_text( :cooperate), do: "Defect"
  defp selection_opposite_text(:defect), do: "Cooperate"

  defp selection_text(:cooperate), do: "Cooperate"
  defp selection_text(:defect), do: "Defect"

end
