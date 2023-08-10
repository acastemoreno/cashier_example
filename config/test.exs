import Config

config :cashier_example, CashierExample.Repo,
  database: "cashier_example_test",
  pool: Ecto.Adapters.SQL.Sandbox
