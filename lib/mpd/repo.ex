defmodule Mpd.Repo do
  use Ecto.Repo,
    otp_app: :mpd,
    adapter: Ecto.Adapters.Postgres
end
