defmodule JoinmyParty.Repo do
  use Ecto.Repo,
    otp_app: :joinmy_party,
    adapter: Ecto.Adapters.Postgres
end
