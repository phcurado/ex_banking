defmodule ExBanking.Transaction do
  @moduledoc """
  Transaction Domain.
  """

  def deposit(_user, amount, _currency) do
    {:ok, amount}
  end
end
