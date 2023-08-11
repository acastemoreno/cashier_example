defmodule CashierExample.Cashier.Product do
  @moduledoc """
  Model for available Product
  """
  use Ecto.Schema

  alias Money.Ecto.Composite.Type, as: MoneyType

  schema "products" do
    field(:code, :string)
    field(:name, :string)
    field(:price, MoneyType)

    timestamps()
  end
end
