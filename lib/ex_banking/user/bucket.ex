defmodule ExBanking.User.Bucket do
  @moduledoc """
  User bucket to store information
  """
  use Agent

  def start_link(name) do
    Agent.start_link(fn -> %{} end, name: name)
  end

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

  def add_amount(user, amount, currency) do
    try do
      add_amount!(user, amount, currency)
    catch
      :exit, _ -> nil
    end
  end

  def add_amount!(user, amount, currency) do
    user
    |> registry_name()
    |> Agent.get_and_update(fn state ->
      case Map.get(state, currency) do
        nil ->
          new_val = Map.put(state, currency, amount)
          {Map.get(new_val, currency), new_val}

        user_amount ->
          new_val = Map.put(state, currency, user_amount + amount)
          {Map.get(new_val, currency), new_val}
      end
    end)
  end

  def registry_name(user) do
    {:via, Registry, {Registry.User, user <> "Bucket"}}
  end
end
