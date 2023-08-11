defmodule CashierExample.Factory.ProductFactory do
  @moduledoc false

  alias CashierExample.Cashier.Product

  defmacro __using__(_opts) do
    quote do
      def product_factory(attrs) do
        %Product{
          code: sequence(:product_code, &"productcode#{&1}"),
          name: sequence(:product_name, &"productname#{&1}"),
          price: Money.new!(:EUR, "10,00")
        }
        |> merge_attributes(attrs)
        |> evaluate_lazy_attributes()
      end
    end
  end
end
