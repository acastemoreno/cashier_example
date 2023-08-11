defmodule CashierExample.Repo.Migrations.AddDealToProducts do
  use Ecto.Migration

  def change do
    execute(
      "CREATE TYPE product_deal_type AS ENUM ('multiple_purchase_free_items', 'multiple_purchase_final_price', 'multiple_purchase_fraction_price')",
      "DROP TYPE product_deal_type"
    )

    alter table("products") do
      add :deal_type, :product_deal_type, null: true
      add :deal_metadata, :map, null: true
    end
  end
end
