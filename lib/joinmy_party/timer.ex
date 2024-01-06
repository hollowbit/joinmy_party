# Game timer utility to help simplify the timer logic
defmodule JoinmyParty.Timer do

  # creates a new timer state and schedules a timeout to call back in 1 second with a new time
  def set_timer(time, pid) do
    # set timeout process
    timeout_ref = Process.send_after pid, {:update_time, time - 1}, 1_000

    # return timer state
    %{
      timeout_ref: timeout_ref,
      time_left_sec: time
    }
  end

  def cancel_timer(%{timeout_ref: ref}), do: Process.cancel_timer(ref)
  def cancel_timer(_), do: :ok

end
