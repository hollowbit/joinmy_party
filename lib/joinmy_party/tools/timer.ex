defmodule JoinmyParty.Timer do

  defstruct [
    pid: nil,
    timeout_ref: nil,
    time_left_sec: 0,
    started: false
  ]

  @doc """
    Creates a new timer state and
  """
  @callback set_timer(time :: integer, pid :: pid) :: %JoinmyParty.Timer{}

  @doc """
    Starts timer by scheduling a timeout to call back in 1 second with a new time
  """
  @callback start_timer(timer :: %JoinmyParty.Timer{}) :: %JoinmyParty.Timer{}
  @callback cancel_timer(timer :: %JoinmyParty.Timer{}) :: %JoinmyParty.Timer{}

  # API
  def set_timer(time, pid), do: impl().set_timer(time, pid)
  def start_timer(timer), do: impl().start_timer(timer)
  def cancel_timer(timer), do: impl().cancel_timer(timer)

  defp impl, do: Application.get_env(:joinmy_party, :game_timer, JoinmyParty.TimerImpl)

end
