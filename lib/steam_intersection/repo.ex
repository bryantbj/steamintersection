defmodule SteamIntersection.Repo do
  use Ecto.Repo,
    otp_app: :steam_intersection,
    adapter: Ecto.Adapters.Postgres
end
