defmodule Twima.Repo do
  use Ecto.Repo,
    otp_app: :twima,
    adapter: Ecto.Adapters.SQLite3
end
