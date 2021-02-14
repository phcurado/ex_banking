defmodule ExBanking.Transaction do
  @moduledoc """
  Transaction Domain.
  """

  def deposit(user, amount, currency) do
    DynamicSupervisor.start_child({:via, Registry, {Registry.User, user}}, {ExBanking.User.Producer, user})
  end
end
