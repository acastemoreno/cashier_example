defmodule CashierExample.Cashier do
  @moduledoc """
  Module to be used by a cashier
  """
  alias CashierExample.Cashier.ProductManager
  alias CashierExample.Cashier.Product

  @type product_code :: String.t()
  @type process_result :: %{total_amount: Money.t(), missing_products: list(product_code())}
  @typep code_summary :: %{required(product_code()) => non_neg_integer()}

  @spec process_basket(String.t()) :: process_result() | {:error, String.t()}
  def process_basket(basket) when is_bitstring(basket) and basket != "" do
    basket
    |> get_list_product_codes()
    |> count_by_code()
    |> process_basket_summary()
  end

  def process_basket(_), do: {:error, "bad input format"}

  @spec get_list_product_codes(String.t()) :: list(product_code())
  defp get_list_product_codes(basket) do
    basket
    |> String.replace(" ", "")
    |> String.downcase()
    |> String.split(",", trim: true)
    |> Enum.map(&String.downcase/1)
  end

  @spec count_by_code(list(product_code())) :: code_summary()
  defp count_by_code(list_codes) do
    Enum.reduce(list_codes, %{}, fn code, acc ->
      Map.update(acc, code, 1, &(&1 + 1))
    end)
  end

  @spec process_basket_summary(code_summary()) :: process_result()
  defp process_basket_summary(summary) do
    available_products = summary |> Map.keys() |> ProductManager.get_products_by_code()

    summary
    |> split_base_on_availability(available_products)
    |> calculate_total_amount()
  end

  @spec split_base_on_availability(code_summary(), list(Product.t())) :: map()
  defp split_base_on_availability(summary, available_products) do
    summary
    |> Enum.reduce(
      %{related: [], unrelated: [], available_products: available_products},
      &split_base_on_availability_reducer/2
    )
    |> Map.delete(:available_products)
  end

  @spec split_base_on_availability_reducer({product_code(), non_neg_integer()}, map()) :: map()
  defp split_base_on_availability_reducer({code, count}, acc) do
    case Enum.find_index(acc.available_products, &(&1.code == code)) do
      nil ->
        Map.update!(acc, :unrelated, &[code | &1])

      product_index ->
        {product, available_products} = List.pop_at(acc.available_products, product_index)

        product_info = %{count: count, product: product}

        acc
        |> Map.update!(:related, &[product_info | &1])
        |> Map.put(:available_products, available_products)
    end
  end

  @spec calculate_total_amount(map()) :: process_result()
  defp calculate_total_amount(%{related: related, unrelated: unrelated}) do
    {:ok, total_amount} =
      related
      |> Enum.map(fn %{count: count, product: product} ->
        ProductManager.calculate_subtotal_amount(product, count)
      end)
      |> Money.sum()

    %{
      total_amount: total_amount,
      missing_products: unrelated
    }
  end
end
