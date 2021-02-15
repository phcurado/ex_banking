defmodule ExBanking.User do
  @moduledoc """
  User Domain Functions.
  """

  @spec create(user :: String.t()) :: :ok | {:error, :user_already_exists | :wrong_arguments}
  def create(user) when is_binary(user) do
    with {:ok, _pid} <-
           DynamicSupervisor.start_child(
             ExBanking.User.DynamicSupervisor,
             {ExBanking.User.Supervisor, %{user: user}}
           ) do
      :ok
    else
      _ -> {:error, :user_already_exists}
    end
  end

  def create(_user), do: {:error, :wrong_arguments}

  def get_balance(user, currency) when is_binary(user) and is_binary(currency) do
    case ExBanking.User.Bucket.get_amount(user, currency) do
      nil -> {:error, :user_does_not_exist}
      amount -> {:ok, amount}
    end
  end

  def get_balance(_user, _currency), do: {:error, :wrong_arguments}
end
