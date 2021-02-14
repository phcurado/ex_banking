defmodule ExBankingTest do
  use ExUnit.Case
  doctest ExBanking

  test "create user" do
    assert ExBanking.create_user("Paulo") == :ok
  end
end
