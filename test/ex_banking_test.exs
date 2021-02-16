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

  describe "send/4" do
    test "Send money from a user to other user" do
      ExBanking.create_user("Marina")
      ExBanking.create_user("Eric")
      ExBanking.deposit("Marina", 50.25, "US")
      assert ExBanking.send("Marina", "Eric", 10.00, "US") == {:ok, 40.25, 10.00}
    end

    test "returns an error when the user receiver don't exist" do
      ExBanking.create_user("Sophia")
      ExBanking.deposit("Sophia", 10.00, "US")

      assert ExBanking.send("Sophia", "Isabella", 10.00, "US") ==
               {:error, :receiver_does_not_exist}
    end

    test "returns an error when the user sender don't exist" do
      ExBanking.create_user("Jefferson")

      assert ExBanking.send("Bianca", "Jefferson", 10.00, "US") ==
               {:error, :sender_does_not_exist}
    end

    test "returns an error when passing wrong arguments" do
      assert ExBanking.send("Marina", :eric, 10.00, "US") == {:error, :wrong_arguments}
      assert ExBanking.send(:marina, "Eric", 30.00, "RUS") == {:error, :wrong_arguments}
      assert ExBanking.send("Marina", "Eric", "20.00", "US") == {:error, :wrong_arguments}
      assert ExBanking.send("Marina", "Eric", 20.00, 10) == {:error, :wrong_arguments}
    end
  end

  describe "concurrent test" do
    test "user with 20 requests should return only 10 times" do
      ExBanking.create_user("Andrade")

      result =
        Enum.map(1..20, fn _ ->
          Task.async(fn ->
            ExBanking.get_balance("Andrade", "R$")
          end)
        end)
        |> Task.await_many()

      ok =
        result
        |> Enum.count(fn res -> res == {:ok, 0} end)

      assert ok == 10

      too_many_requests_to_user =
        result
        |> Enum.count(fn res -> res == {:error, :too_many_requests_to_user} end)

      assert too_many_requests_to_user == 10
    end
  end
end
