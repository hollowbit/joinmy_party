ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(JoinmyParty.Repo, :manual)

# Mocks
Mox.defmock(JoinmyParty.TimerMock, for: JoinmyParty.Timer)
Application.put_env(:joinmy_party, :game_timer, JoinmyParty.TimerMock)
