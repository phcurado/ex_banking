defmodule ExBanking.User do
  @moduledoc """
  User Domain.
  """

  def create(user) when is_bitstring(user) do
    with {:ok, _pid} <- DynamicSupervisor.start_child(ExBanking.User.DynamicSupervisor, {ExBanking.User.Supervisor, %{user: user}}) do
      :ok
    else
      _ -> {:error, :user_already_exists}
    end
  end

  def create(_user) do
    {:error, :wrong_arguments}
  end
end
