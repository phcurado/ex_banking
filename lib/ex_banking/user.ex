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
      {:error, {:already_started, _pid}} -> {:error, :user_already_exists}
    end
  end

  def create(_user), do: {:error, :wrong_arguments}

  @spec deposit(user :: String.t(), amount :: number(), currency :: String.t()) ::
          {:error, :user_does_not_exist | :wrong_arguments}
          | {:ok,
             {:deposit, %{amount: number, currency: binary, user: binary}}
             | {:error, :not_enough_money}
             | {:withdraw, %{amount: number, currency: binary, user: binary}}}
  def deposit(user, amount, currency)
      when is_binary(user) and
             is_number(amount) and
             is_binary(currency) and amount > 0 do
    case ExBanking.User.Producer.sync_notify(
           {:deposit, %{user: user, amount: amount, currency: currency}}
         ) do
      {:error, :not_found} -> {:error, :user_does_not_exist}
      new_balance -> {:ok, new_balance}
    end
  end

  def deposit(_user, _amount, _currency), do: {:error, :wrong_arguments}

  @spec withdraw(user :: String.t(), amount :: number(), currency :: String.t()) ::
          {:error, :not_enough_money | :user_does_not_exist | :wrong_arguments}
          | {:ok,
             {:deposit, %{amount: number, currency: String.t(), user: String.t()}}
             | {:withdraw, %{amount: number, currency: String.t(), user: String.t()}}}
  def withdraw(user, amount, currency)
      when is_binary(user) and
             is_number(amount) and
             is_binary(currency) and
             amount > 0 do
    case ExBanking.User.Producer.sync_notify(
           {:withdraw, %{user: user, amount: amount, currency: currency}}
         ) do
      {:error, :not_found} -> {:error, :user_does_not_exist}
      {:error, :not_enough_money} -> {:error, :not_enough_money}
      new_balance -> {:ok, new_balance}
    end
  end

  def withdraw(_user, _amount, _currency), do: {:error, :wrong_arguments}

  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:error, :user_does_not_exist | :wrong_arguments}
          | {:ok,
             {:deposit, %{amount: number, currency: binary, user: binary}}
             | {:error, :not_enough_money}
             | {:withdraw, %{amount: number, currency: binary, user: binary}}}
  def get_balance(user, currency)
      when is_binary(user) and is_binary(currency) do
    case ExBanking.User.Producer.sync_notify({:get_balance, %{user: user, currency: currency}}) do
      {:error, :not_found} -> {:error, :user_does_not_exist}
      amount -> {:ok, amount}
    end
  end

  def get_balance(_user, _currency), do: {:error, :wrong_arguments}
end
