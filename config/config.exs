import Config

config :ex_cldr,
  json_library: Jason,
  default_backend: CashierExample.Cldr

config :cashier_example, CashierExample.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5432"

config :cashier_example, ecto_repos: [CashierExample.Repo]

import_config "#{config_env()}.exs"
