defmodule JoinmyPartyWeb.LiveTester do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    new_state = %{
      team_a_selection: :defect,
      team_b_selection: :defect,
      team_a_points_earned: -5,
      team_b_points_earned: 10,
      round: 2,
      team: :team_a
    }

    round_results = %{
      id: "pdilemma-round-end-modal",
      open: true,
      last_round_selection: :cooperate,
      other_team_selection: :cooperate,
      last_round_points_earned: 5,
      round: 2
    }

    send_update(PdilemmaWeb.RoundEndModal, round_results)
    {:ok, assign(socket, new_state) |> push_event("show-modal", %{to: "round-end-modal"})}
  end


  def render(assigns) do
    ~H"""

    <.live_component module={PdilemmaWeb.RoundEndModal} id="round-end-modal" />

    <button phx-click="show-modal" phx-target="#round-end-modal" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">Show Modal</button>
    """
  end
end
