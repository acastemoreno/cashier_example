defmodule CashierExample.Repo do
  use Ecto.Repo,
    otp_app: :cashier_example,
    adapter: Ecto.Adapters.Postgres
end
