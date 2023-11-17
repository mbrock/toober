defmodule Tooba.Repo do
  use Ecto.Repo,
    otp_app: :tooba,
    adapter: Ecto.Adapters.SQLite3
end
