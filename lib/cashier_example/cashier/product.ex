defmodule CashierExample.Cashier.Product do
  @moduledoc """
  Model for available Product
  """
  use Ecto.Schema

  alias Money.Ecto.Composite.Type, as: MoneyType

  @type t :: %__MODULE__{
    code: String.t(),
    name: String.t(),
    price: Money.t(),
  }

  schema "products" do
    field(:code, :string)
    field(:name, :string)
    field(:price, MoneyType)

    timestamps()
  end
end
