defmodule CashierExampleTest.CashierTest do
  use CashierExample.RepoCase, async: true
  import Money.Sigil

  alias CashierExample.Cashier

  describe "process_basket/1" do
    setup do
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

      :ok
    end

    for bad_input <- ["", 1, :random] do
      test "return bad_input on #{bad_input}" do
        bad_input = unquote(bad_input)

        assert {:error, :bad_input} = Cashier.process_basket(bad_input)
      end
    end

    for {basket, expect_amount} <- [
          {"GR1,SR1,GR1,GR1,CF1", "22.45"},
          {"GR1,GR1", "3.11"},
          {"SR1,SR1,GR1,SR1", "16.61"},
          {"GR1,CF1,SR1,CF1,CF1", "30.57"},
          ## Additional tests
          {"SR1,SR1,SR1,SR1", "18"},
          {"CF1,CF1,CF1,CF1,CF1,CF1,CF1", "52.41"}
        ] do
      test "with basket: #{basket}" do
        basket = unquote(basket)
        expect_amount = Money.new!(:EUR, unquote(expect_amount))

        assert %{
                 total_amount: %Money{} = total_amount,
                 missing_products: missing_products
               } = Cashier.process_basket(basket)

        assert Money.equal?(total_amount, expect_amount)
        assert missing_products == []
      end
    end

    test "return two decimals (min unit for cash purpose)" do
      basket = "CF1,CF1,CF1,CF1"
      expect_amount = Money.new!(:EUR, "29.95")

      assert %{
               total_amount: %Money{} = total_amount,
               missing_products: missing_products
             } = Cashier.process_basket(basket)

      assert Money.equal?(total_amount, expect_amount)
      assert missing_products == []
    end

    test "return product_code not registered and total amount of registered ones" do
      basket = "GR1,SR1,GR1,GR1,CF1,RANDOM_CODE1,RANDOM_CODE2,RANDOM_CODE1"
      expect_amount = Money.new!(:EUR, "22.45")

      assert %{
               total_amount: %Money{} = total_amount,
               missing_products: missing_products
             } = Cashier.process_basket(basket)

      assert Money.equal?(total_amount, expect_amount)
      assert Enum.sort(missing_products) == Enum.sort(["random_code1", "random_code2"])
    end

    test "return unique product_code not registered and zero total amount" do
      basket = "RANDOM_CODE1,RANDOM_CODE2,RANDOM_CODE1"
      expect_amount = Money.zero(:EUR)

      assert %{
               total_amount: %Money{} = total_amount,
               missing_products: missing_products
             } = Cashier.process_basket(basket)

      assert Money.equal?(total_amount, expect_amount)
      assert Enum.sort(missing_products) == Enum.sort(["random_code1", "random_code2"])
    end
  end
end
