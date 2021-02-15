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
      :exit, _ -> nil
    end
  end

  def get_amount!(user, currency) do
    user
    |> registry_name()
    |> Agent.get(&(&1))
    |> Map.get(currency)
  end

  def add_amount(user, currency, amount) do
    try do
      add_amount!(user, currency, amount)
    catch
      :exit, _ -> nil
    end
  end

  def add_amount!(user, currency, amount) do
    user
    |> registry_name()
    |> Agent.update(fn bucket ->
      case Map.get(bucket, currency) do
        nil ->
          Map.put(bucket, currency, amount)
        user_amount ->
          Map.put(bucket, currency, user_amount + amount)
      end
    end)
  end

  def registry_name(user) do
    {:via, Registry, {Registry.User, user <> "Bucket"}}
  end
end
