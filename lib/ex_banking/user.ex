defmodule ExBanking.User do
  @moduledoc """
  User Domain Functions.
  """

  alias ExBanking.User.Producer.EventParam
  alias ExBanking.Money

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
          {:ok, integer()} | {:error, atom()}
  def deposit(user, amount, currency)
      when is_binary(user) and
             is_number(amount) and
             is_binary(currency) and amount > 0 do
    with {:ok, new_balance} <-
           ExBanking.User.Producer.sync_notify(
             {:deposit,
              %EventParam{user: user, amount: Money.parse_to_int(amount), currency: currency}}
           ) do
      {:ok, Money.load(new_balance)}
    else
      {:error, :not_found, _event} -> {:error, :user_does_not_exist}
      {:error, :too_many_requests_to_user, _event} -> {:error, :too_many_requests_to_user}
    end
  end

  def deposit(_user, _amount, _currency), do: {:error, :wrong_arguments}

  @spec withdraw(user :: String.t(), amount :: number(), currency :: String.t()) ::
          {:ok, integer()}
          | {:error, atom()}
  def withdraw(user, amount, currency)
      when is_binary(user) and
             is_number(amount) and
             is_binary(currency) and
             amount > 0 do
    with {:ok, new_balance} <-
           ExBanking.User.Producer.sync_notify(
             {:withdraw,
              %EventParam{user: user, amount: Money.parse_to_int(amount), currency: currency}}
           ) do
      {:ok, Money.load(new_balance)}
    else
      {:error, :not_found, _event} -> {:error, :user_does_not_exist}
      {:error, :not_enough_money, _event} -> {:error, :not_enough_money}
      {:error, :too_many_requests_to_user, _event} -> {:error, :too_many_requests_to_user}
    end
  end

  def withdraw(_user, _amount, _currency), do: {:error, :wrong_arguments}

  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:ok, integer()}
          | {:error, atom()}
  def get_balance(user, currency)
      when is_binary(user) and is_binary(currency) do
    with {:ok, amount} <-
           ExBanking.User.Producer.sync_notify(
             {:get_balance, %EventParam{user: user, currency: currency}}
           ) do
      {:ok, Money.load(amount)}
    else
      {:error, :not_found, _event} -> {:error, :user_does_not_exist}
      {:error, :too_many_requests_to_user, _event} -> {:error, :too_many_requests_to_user}
    end
  end

  def get_balance(_user, _currency), do: {:error, :wrong_arguments}

  def send(from_user, to_user, amount, currency)
      when is_binary(from_user) and
             is_binary(to_user) and
             is_number(amount) and
             is_binary(currency) and
             amount > 0 do
    with {:ok, from_user_balance} <-
           ExBanking.User.Producer.sync_notify(
             {:withdraw,
              %EventParam{user: from_user, amount: Money.parse_to_int(amount), currency: currency}}
           ),
         {:ok, to_user_balance} <-
           ExBanking.User.Producer.sync_notify(
             {:deposit,
              %EventParam{user: to_user, amount: Money.parse_to_int(amount), currency: currency}}
           ) do
      {:ok, Money.load(from_user_balance), Money.load(to_user_balance)}
    else
      {:error, :not_found, :withdraw} ->
        {:error, :sender_does_not_exist}

      {:error, :not_found, :deposit} ->
        {:error, :receiver_does_not_exist}

      {:error, :too_many_requests_to_user, :withdraw} ->
        {:error, :too_many_requests_to_sender}

      {:error, :too_many_requests_to_user, :deposit} ->
        # rollback the transaction with top priority
        ExBanking.User.Producer.sync_notify(
          {:deposit,
           %EventParam{
             user: from_user,
             amount: Money.parse_to_int(amount),
             currency: currency,
             priority: :top
           }}
        )

        {:error, :too_many_requests_to_receiver}

      {:error, :not_enough_money, _event} ->
        {:error, :not_enough_money}
    end
  end

  def send(_from_user, _to_user, _amount, _currency), do: {:error, :wrong_arguments}
end
