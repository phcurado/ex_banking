defmodule ExBanking.User.Server do
  @moduledoc false

  use GenServer

  require Logger

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def create_user(user) when is_bitstring(user) do
    GenServer.cast(__MODULE__, {:create_user, user})
  end

  @impl true
  def init(_args) do
    {:ok, %{}}
  end

  @impl true
  def handle_cast({:create_user, user}, state) do
    with {:ok, _pid} <- start_user_supervisor(user) do
      Logger.info("created user #{user}")
      {:noreply, user, state}
    else
      error ->
        Logger.error(error)
        {:noreply, state}
    end
  end

  defp start_user_supervisor(user) do
    DynamicSupervisor.start_child(ExBanking.User.DynamicSupervisor, {ExBanking.User.Supervisor, %{user: user}})
  end
end
