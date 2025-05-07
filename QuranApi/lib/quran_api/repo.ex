defmodule QuranApi.Repo do
  use Ecto.Repo,
    otp_app: :quran_api,
    adapter: Ecto.Adapters.Postgres
end
