defmodule PdilemmaWeb.RoundEndModal do
  # In Phoenix apps, the line is typically: use MyAppWeb, :html
  use Phoenix.Component
  alias Phoenix.LiveView.JS


  def modal(assigns) do
    ~H"""
    <dialog id="pdilemma-round-end-modal" class="w-10/12 max-w-2xl min-h-96 p-4 rounded-md shadow-md shadow-slate-800 text-slate-800" phx-update="ignore" onclick="document.getElementById('pdilemma-round-end-modal').close();">
        <span class="top-2 float-right mr-2 font-bold text-3xl text-slate-700 cursor-pointer" >✖</span>
        <h3>Round End</h3>
    </dialog>
    """
  end

end
