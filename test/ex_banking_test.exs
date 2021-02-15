defmodule ExBankingTest do
  use ExUnit.Case

  describe "create_user/1" do
    test "create a new user" do
      assert ExBanking.create_user("Paulo") == :ok
    end

    test "returns an error when the user already exists" do
      ExBanking.create_user("Rafael")
      assert ExBanking.create_user("Rafael") == {:error, :user_already_exists}
    end

    test "returns an error when passing wrong arguments" do
      assert ExBanking.create_user(:rafael) == {:error, :wrong_arguments}
      assert ExBanking.create_user(22) == {:error, :wrong_arguments}
    end
  end

  describe "deposit/3" do
    test "Deposit money to a user" do
      ExBanking.create_user("Carlos")
      assert ExBanking.deposit("Carlos", 20.00, "R$") == {:ok, 20.00}
      assert ExBanking.deposit("Carlos", 33.10, "R$") == {:ok, 53.10}
      assert ExBanking.deposit("Carlos", 10.50, "€") == {:ok, 10.50}
    end

    test "returns an error when the user don't exist" do
      assert ExBanking.deposit("Vinicius", 10.50, "€") == {:error, :user_does_not_exist}
    end

    test "returns an error when passing wrong arguments" do
      assert ExBanking.deposit("Paulo", 20.00, :coin) == {:error, :wrong_arguments}
      assert ExBanking.deposit("Paulo", "30.00", "R$") == {:error, :wrong_arguments}
      assert ExBanking.deposit(:paulo, 40.00, "R$") == {:error, :wrong_arguments}
      assert ExBanking.deposit("Paulo", -30.00, "EU") == {:error, :wrong_arguments}
    end
  end

  describe "withdraw/3" do
    test "Withdraw money from user" do
      ExBanking.create_user("Bill")
      assert ExBanking.withdraw("Bill", 5.00, "R$") == {:error, :not_enough_money}
      assert ExBanking.withdraw("Bill", 5.00, "€") == {:error, :not_enough_money}
      assert ExBanking.deposit("Bill", 10.00, "R$") == {:ok, 10.00}
      assert ExBanking.withdraw("Bill", 3.00, "R$") == {:ok, 7.00}
      assert ExBanking.withdraw("Bill", 4.00, "R$") == {:ok, 3.00}
      assert ExBanking.withdraw("Bill", 3.00, "R$") == {:ok, 0.00}
      assert ExBanking.withdraw("Bill", 3.00, "R$") == {:error, :not_enough_money}
    end

    test "returns an error when the user don't exist" do
      assert ExBanking.withdraw("Vinicius", 10.50, "R$") == {:error, :user_does_not_exist}
    end

    test "returns an error when passing wrong arguments" do
      assert ExBanking.withdraw("Paulo", 20.00, :coin) == {:error, :wrong_arguments}
      assert ExBanking.withdraw("Paulo", "30.00", "R$") == {:error, :wrong_arguments}
      assert ExBanking.withdraw(:paulo, 40.00, "R$") == {:error, :wrong_arguments}
      assert ExBanking.withdraw("Paulo", -20.50, "BRL") == {:error, :wrong_arguments}
    end
  end

  describe "get_balance/2" do
    test "get balance from user" do
      ExBanking.create_user("Jonas")
      assert ExBanking.get_balance("Jonas", "R$") == {:ok, 0.00}
      assert ExBanking.get_balance("Jonas", "EUR") == {:ok, 0.00}
    end

    test "returns an error when the user don't exist" do
      assert ExBanking.get_balance("Vinicius", "R$") == {:error, :user_does_not_exist}
    end

    test "returns an error when passing wrong arguments" do
      assert ExBanking.get_balance("Paulo", :coin) == {:error, :wrong_arguments}
      assert ExBanking.get_balance(:paulo, "R$") == {:error, :wrong_arguments}
    end
  end
end
