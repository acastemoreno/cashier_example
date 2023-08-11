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
          deal_type: atom(),
          deal_metadata: map()
        }

  schema "products" do
    field(:code, :string)
    field(:name, :string)
    field(:price, MoneyType)

    field(:deal_type, Ecto.Enum,
      values: [
        :multiple_purchase_free_items,
        :multiple_purchase_final_price,
        :multiple_purchase_fraction_price
      ]
    )

    embeds_one :deal_metadata, DealMetadata do
      field(:count_trigger, :integer)
      field(:free_items, :integer)
      field(:final_price_amount, :string)
      field(:fraction_price, :string)
    end

    timestamps()
  end
end
