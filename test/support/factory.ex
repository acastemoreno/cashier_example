defmodule CashierExample.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: CashierExample.Repo

  use CashierExample.Factory.ProductFactory
end
