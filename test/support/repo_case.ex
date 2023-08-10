defmodule CashierExample.RepoCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  using do
    quote do
      alias MyApp.Repo

      import Ecto
      import Ecto.Query
      import CashierExample.RepoCase

      # and any other stuff
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(CashierExample.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(CashierExample.Repo, {:shared, self()})
    end

    :ok
  end
end
