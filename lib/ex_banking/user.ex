defmodule ExBanking.User do
  @moduledoc """
  User Domain.
  """

  def create(user) do
    DynamicSupervisor.start_child(ExBanking.User.DynamicSupervisor, {ExBanking.User.Supervisor, %{user: user}})
  end
end
