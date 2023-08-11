defmodule CashierExample.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :code, :string
      add :name, :string
      add :price, :money_with_currency

      timestamps()
    end

    create unique_index("products", [:code])
  end
end
