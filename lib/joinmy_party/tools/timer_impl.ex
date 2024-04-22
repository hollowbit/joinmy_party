defmodule JoinmyParty.TimerImpl do
  @behaviour JoinmyParty.Timer

  def set_timer(time, pid) do
    %JoinmyParty.Timer{pid: pid, time_left_sec: time}
  end

  def start_timer(%JoinmyParty.Timer{} = timer) do
    timeout_ref = Process.send_after timer.pid, {:update_time, %{timer | time_left_sec: timer.time_left_sec - 1}}, 1_000
    %{timer | timeout_ref: timeout_ref, started: true}
  end

  def cancel_timer(timer = %JoinmyParty.Timer{timeout_ref: ref}) when not timer.started do
    Process.cancel_timer(ref)
    %{timer | timeout_ref: nil, started: false}
  end
  def cancel_timer(timer), do: %{timer | started: false}

end
