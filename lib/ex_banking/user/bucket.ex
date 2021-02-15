defmodule ExBanking.User.Bucket do
  @moduledoc """
  User bucket to store user information
  """
  use Agent

  def start_link(name) do
    Agent.start_link(fn -> %{} end, name: name)
  end

  @doc "Returns the user money amount"
  @spec get_amount(user :: String.t(), currency :: String.t()) :: number() | {:error, :not_found}
  def get_amount(user, currency) do
    try do
      get_amount!(user, currency)
    catch
      :exit, _ -> {:error, :not_found}
    end
  end

  def get_amount!(user, currency) do
    user
    |> registry_name()
    |> Agent.get(& &1)
    |> Map.get(currency)
    |> case do
      nil -> 0
      amount -> amount
    end
  end

  @doc "Will decrease the user money amount with the given amount and currency"
  def decrease_amount(user, amount, currency) do
    try do
      decrease_amount!(user, amount, currency)
    catch
      :exit, _ -> {:error, :not_found}
    end
  end

  def decrease_amount!(user, amount, currency) do
    old_amount = get_amount(user, currency)
    new_balance = old_amount - amount
    update_user_balance(user, new_balance, currency)
  end

  @doc "Will increase the user money amount with the given amount and currency"
  def add_amount(user, amount, currency) do
    try do
      add_amount!(user, amount, currency)
    catch
      :exit, _ -> {:error, :not_found}
    end
  end

  def add_amount!(user, amount, currency) do
    old_amount = get_amount(user, currency)
    new_balance = old_amount + amount
    update_user_balance(user, new_balance, currency)
  end

  def update_user_balance(user, new_balance, currency) when new_balance >= 0 do
    user
    |> registry_name()
    |> Agent.get_and_update(fn state ->
      case Map.get(state, currency) do
        nil ->
          new_val = Map.put(state, currency, new_balance)
          {Map.get(new_val, currency), new_val}

        _ ->
          new_val = Map.put(state, currency, new_balance)
          {Map.get(new_val, currency), new_val}
      end
    end)
  end

  def update_user_balance(_bucket_state, _currency, _balance) do
    {:error, :not_enough_money}
  end

  def registry_name(user) do
    {:via, Registry, {Registry.User, user <> "Bucket"}}
  end
end
