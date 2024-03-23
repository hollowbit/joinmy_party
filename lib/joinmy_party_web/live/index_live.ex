defmodule JoinmyPartyWeb.IndexWebLive do
  use JoinmyPartyWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="p-8">
      <h1 class="font-bold text-6xl text-slate-800 text-center">JoinMy.Party</h1>
      <h2 class="uppercase italic text-xl text-slate-500 text-center">Play interactive games with friends online or in-person <span class="not-italic">📱</span></h2>


      <p class="text-center">Currently, the only game available is Prisoner's Dilemma. <a class="cursor-pointer" onclick={JoinmyPartyWeb.PdilemmaWebRules.onclick}>Rules 🛈</a></p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

end
