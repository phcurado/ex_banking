defmodule ExBanking.Money do
  @moduledoc """
  Module implementation for dealing with money amount
  """

  @doc """
  Load the money to show to the user

      iex>ExBanking.Money.load(10000)
      100.0
      iex>ExBanking.Money.load(2545)
      25.45
  """
  def load(amount) when is_number(amount) do
    amount / 100
  end

  def load(_amount) do
    {:error, :not_number}
  end

  @doc """
  Parse amount to integer coming from user input
      iex>ExBanking.Money.parse_to_int(10.459)
      1045
      iex>ExBanking.Money.parse_to_int(10.05)
      1025
  """
  def parse_to_int(amount) when is_number(amount) do
    floor(amount * 100)
  end

  def parse_to_int(_amount) do
    {:error, :not_number}
  end
end
