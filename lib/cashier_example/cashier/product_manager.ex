defmodule CashierExample.Cashier.ProductManager do
  @moduledoc """
  Manager for Product model
  """
  alias CashierExample.Cashier.Product
  alias CashierExample.Repo

  import Ecto.Query

  @spec get_products_by_code(nonempty_list(String.t())) :: list(Product.t())
  def get_products_by_code(product_codes) do
    Product
    |> where([p], p.code in ^product_codes)
    |> Repo.all()
  end

  @spec calculate_subtotal_amount(Product.t(), non_neg_integer()) :: Money.t()
  def calculate_subtotal_amount(%Product{price: price, deal_type: nil}, count) do
    Money.mult!(price, count)
  end

  def calculate_subtotal_amount(
        %Product{
          price: price,
          deal_type: :multiple_purchase_free_items,
          deal_metadata: deal_metadata
        },
        count
      ) do
    group_count = deal_metadata.count_trigger + deal_metadata.free_items

    partial_purchase = div(count, group_count)
    full_purchase = rem(count, group_count)

    factor = deal_metadata.count_trigger * partial_purchase + full_purchase

    Money.mult!(price, factor)
  end

  def calculate_subtotal_amount(
        %Product{
          price: price,
          deal_type: :multiple_purchase_final_price,
          deal_metadata: deal_metadata
        },
        count
      ) do
    if count >= deal_metadata.count_trigger do
      final_price = Money.new!(price.currency, deal_metadata.final_price_amount)

      Money.mult!(final_price, count)
    else
      Money.mult!(price, count)
    end
  end

  def calculate_subtotal_amount(
        %Product{
          price: price,
          deal_type: :multiple_purchase_fraction_price,
          deal_metadata: deal_metadata
        },
        count
      ) do
    if count >= deal_metadata.count_trigger do
      [numerator, denominador] =
        deal_metadata.fraction_price
        |> String.split("/")
        |> Enum.map(&String.to_integer/1)

      price
      |> Money.mult!(count * numerator)
      |> Money.div!(denominador)
    else
      Money.mult!(price, count)
    end
  end
end
