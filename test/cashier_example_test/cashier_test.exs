defmodule CashierExampleTest.CashierTest do
  use CashierExample.RepoCase, async: true

  alias CashierExample.Cashier

  describe "process_basket/1" do
    setup do
      insert(:product, code: "gr1", name: "Green tea", price: Money.new!(:EUR, "3.11"))
      insert(:product, code: "sr1", name: "Strawberries", price: Money.new!(:EUR, "5.00"))
      insert(:product, code: "cf1", name: "Coffee", price: Money.new!(:EUR, "11.23"))

      :ok
    end

    for {basket, expect_amount} <- [
          {"GR1,SR1,GR1,GR1,CF1", "22.45"},
          {"GR1,GR1", "3.11"},
          {"SR1,SR1,GR1,SR1", "16.61"},
          {"GR1,CF1,SR1,CF1,CF1", "30.57"}
        ] do
      test "test basket: #{basket}" do
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
  end
end
