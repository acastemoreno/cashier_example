defmodule CashierExampleTest do
  use ExUnit.Case
  doctest CashierExample

  test "greets the world" do
    assert CashierExample.hello() == :world
  end
end
