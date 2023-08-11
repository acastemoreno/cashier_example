defmodule CashierExample.Casier.ProductManagerTest do
  use CashierExample.RepoCase, async: true
  import Money.Sigil

  alias CashierExample.Cashier.ProductManager

  describe "get_products_by_code/1" do
    setup do
      gr1 =
        insert(:product,
          code: "gr1",
          name: "Green tea",
          price: ~M[3.11]eur,
          deal_type: :multiple_purchase_free_items,
          deal_metadata: %{
            count_trigger: 1,
            free_items: 1
          }
        )

      sr1 =
        insert(:product,
          code: "sr1",
          name: "Strawberries",
          price: ~M[5.00]eur,
          deal_type: :multiple_purchase_final_price,
          deal_metadata: %{
            count_trigger: 3,
            final_price_amount: "4.5"
          }
        )

      cf1 =
        insert(:product,
          code: "cf1",
          name: "Coffee",
          price: ~M[11.23]eur,
          deal_type: :multiple_purchase_fraction_price,
          deal_metadata: %{
            count_trigger: 3,
            fraction_price: "2/3"
          }
        )

      %{gr1: gr1, sr1: sr1, cf1: cf1}
    end

    test "fetch products by product code list", %{gr1: gr1, cf1: cf1} do
      products = ProductManager.get_products_by_code(["gr1", "cf1"])

      assert Enum.sort(products) == Enum.sort([gr1, cf1])
    end
  end

  describe "calculate_subtotal_amount/2" do
    test "wihout deal" do
      product = insert(:product, price: ~M[3.33]eur)

      total_amount = ProductManager.calculate_subtotal_amount(product, 5)
      assert Money.equal?(total_amount, ~M[16.65]eur)
    end

    test "about a multiple_purchase_free_items, didn't reach minimum for deal" do
      product =
        insert(:product,
          code: "gr1",
          name: "Green tea",
          price: ~M[3.00]eur,
          deal_type: :multiple_purchase_free_items,
          deal_metadata: %{
            count_trigger: 3,
            free_items: 1
          }
        )

      total_amount = ProductManager.calculate_subtotal_amount(product, 2)
      assert Money.equal?(total_amount, ~M[6.00]eur)
    end

    test "about a multiple_purchase_free_items, reach minimum for deal" do
      product =
        insert(:product,
          code: "gr1",
          name: "Green tea",
          price: ~M[3.00]eur,
          deal_type: :multiple_purchase_free_items,
          deal_metadata: %{
            count_trigger: 2,
            free_items: 1
          }
        )

      total_amount = ProductManager.calculate_subtotal_amount(product, 4)
      assert Money.equal?(total_amount, ~M[9.00]eur)
    end

    test "about a multiple_purchase_final_price, didn't reach minimum for deal" do
      product =
        insert(:product,
          code: "gr1",
          name: "Green tea",
          price: ~M[3.66]eur,
          deal_type: :multiple_purchase_final_price,
          deal_metadata: %{
            count_trigger: 4,
            final_price_amount: "3.00"
          }
        )

      total_amount = ProductManager.calculate_subtotal_amount(product, 3)
      assert Money.equal?(total_amount, ~M[10.98]eur)
    end

    test "about a multiple_purchase_final_price, reach minimum for deal" do
      product =
        insert(:product,
          code: "gr1",
          name: "Green tea",
          price: ~M[3.66]eur,
          deal_type: :multiple_purchase_final_price,
          deal_metadata: %{
            count_trigger: 4,
            final_price_amount: "3.00"
          }
        )

      total_amount = ProductManager.calculate_subtotal_amount(product, 10)
      assert Money.equal?(total_amount, ~M[30.00]eur)
    end

    test "about a multiple_purchase_fraction_price, didn't reach minimum for deal" do
      product =
        insert(:product,
          code: "gr1",
          name: "Green tea",
          price: ~M[3.33]eur,
          deal_type: :multiple_purchase_fraction_price,
          deal_metadata: %{
            count_trigger: 4,
            fraction_price: "2/5"
          }
        )

      total_amount = ProductManager.calculate_subtotal_amount(product, 3)
      assert Money.equal?(total_amount, ~M[9.99]eur)
    end

    test "about a multiple_purchase_fraction_price, reach minimum for deal" do
      product =
        insert(:product,
          code: "gr1",
          name: "Green tea",
          price: ~M[4.00]eur,
          deal_type: :multiple_purchase_fraction_price,
          deal_metadata: %{
            count_trigger: 4,
            fraction_price: "1/3"
          }
        )

      total_amount = ProductManager.calculate_subtotal_amount(product, 7)

      assert Money.equal?(
               Money.round(total_amount),
               ~M[9.33]eur
             )
    end
  end
end
