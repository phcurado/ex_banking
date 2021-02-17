defmodule ExBanking.MoneyTest do
  use ExUnit.Case

  alias ExBanking.Money

  describe "load/1" do
    test "should load with the correct decimal place" do
      assert Money.load(1050) == 10.50
      assert Money.load(10) == 0.10
      assert Money.load(1900) == 19
    end

    test "should fail if is not a number" do
      assert Money.load("1050") == {:error, :not_number}
      assert Money.load(:test) == {:error, :not_number}
    end
  end

  describe "parse/1" do
    test "should parse to integer" do
      assert Money.parse_to_int(10.50) == 1050
      assert Money.parse_to_int(10) == 1000
      assert Money.parse_to_int(19.00) == 1900
      assert Money.parse_to_int(19.789) == 1978
      assert Money.parse_to_int(500.55988) == 50055
      assert Money.parse_to_int(500.551) == 50055
    end

    test "should fail if is not a number" do
      assert Money.parse_to_int("1050") == {:error, :not_number}
      assert Money.parse_to_int(:test) == {:error, :not_number}
    end
  end
end
