defmodule JoinmyPartyWeb.PdilemmaWebRules do
  # In Phoenix apps, the line is typically: use MyAppWeb, :html
  use Phoenix.Component

  def index(assigns) do
    ~H"""
      <dialog id="pdilemma-rules-modal" class="w-10/12 max-w-2xl min-h-96 p-4 rounded-md shadow-md shadow-slate-800 text-slate-800" onclick="document.getElementById('pdilemma-rules-modal').close();">
        <span class="top-2 float-right mr-2 font-bold text-3xl text-slate-700 cursor-pointer" >✖</span>
        <h1 class="text-center text-2xl m-3 font-bold underline">RULES for The Prisoner's Dilemma</h1>
        <p class="text-slate-600 text-sm">Game Time: 30min</p>
        <p class="text-slate-600 text-sm">Players: 2+</p>
        <p class="mt-2">Two teams cooperate or compete in a game of friendly negociation, and back-stabbing betrayal.</p>
        <br>
        <p>Games lasts 6 rounds, and on every round each team must choose to either <span class="text-green-500 italic">COOPERATE</span> or <span class="text-red-500 italic">DEFECT</span>. When the 5 minute timer for the round ends, points are given as follows:</p>
        <br>
        <table class="[&_td]:border-t-2 [&_td]:p-2 w-full max-w-96 mx-auto">
          <tr>
            <th>Choices</th>
            <th>Points</th>
          </tr>
          <tr>
            <td>Both teams <span class="text-green-500 italic">COOPERATE</span></td>
            <td>+5 points for both teams</td>
          </tr>
          <tr>
            <td>Both teams <span class="text-red-500 italic">DEFECT</span></td>
            <td>-5 points for both teams</td>
          </tr>
          <tr>
            <td>Team A <span class="text-green-500 italic">COOPERATES</span><br>Team B <span class="text-red-500 italic">DEFECTS</span></td>
            <td>-10 points for Team A<br>+10 points for Team B</td>
          </tr>
          <tr>
            <td>Team A <span class="text-red-500 italic">DEFECTS</span><br>Team B <span class="text-green-500 italic">COOPERATES</span></td>
            <td>+10 points for Team A<br>-10 points for Team B</td>
          </tr>
        </table>
        <p class="text-center text-sm italic">You get more points if your team defects when the other team tries to cooperate.</p>
        <br>
        <p>Both teams should be in separate rooms where they cannot hear chatter from the other team. Each round, teams may pick and send an ambassador to negociate with the other team in a neutral area. No spying! 🕵️</p>
        <br>
        <p>The team with the most points by the end of the game is the winner 🎉</p>
        <p>Have fun!</p>
      </dialog>
    """
  end

  def onclick() do
    """
    document.getElementById('pdilemma-rules-modal').showModal();
    """
  end

end
