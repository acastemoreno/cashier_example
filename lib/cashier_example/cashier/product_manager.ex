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
  def calculate_subtotal_amount(%Product{price: price}, count) do
    Money.mult!(price, count)
  end
end
