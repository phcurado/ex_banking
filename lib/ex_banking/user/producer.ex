defmodule ExBanking.User.Producer do
  @moduledoc """
  User producer logic following the `GenStage` documentation.
  Here we can call the `sync_notify` function for passing events to our consumer.

  ## Example
      iex> ExBanking.User.Producer.sync_notify({:deposit, %{user: "Paulo", amount: 2.00, currency: "BRL"}})
      2.0
  """

  use GenStage

  @type event_balance :: {:get_balance, %{user: String.t(), currency: String.t()}}
  @type event ::
          {:deposit | :withdraw, %{user: String.t(), amount: number(), currency: String.t()}}

  @doc "Starts the user producer."
  def start_link(name) do
    GenStage.start_link(__MODULE__, :ok, name: name)
  end

  @doc "Sends an event and returns only after the event is dispatched."
  @spec sync_notify(event | event_balance, :infinity | non_neg_integer) ::
          event | {:error, :not_found} | {:error, :not_enough_money}
  def sync_notify({_, %{user: user}} = event, timeout \\ 5000) do
    case registry_exists?(user) do
      true -> GenStage.call(registry_name(user), {:notify, event}, timeout)
      false -> {:error, :not_found}
    end
  end

  @doc "Name registry for User Producer"
  def registry_name(user) do
    {:via, Registry, {Registry.User, user <> "Producer"}}
  end

  @doc "Checks if the user producer exists"
  @spec registry_exists?(user :: String.t()) :: boolean
  def registry_exists?(user) do
    case Registry.lookup(Registry.User, user <> "Producer") do
      [] -> false
      _ -> true
    end
  end

  ## Callbacks

  def init(:ok) do
    {:producer, {:queue.new(), 0}, dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_call({:notify, event}, from, {queue, pending_demand}) when pending_demand > 0 do
    queue = :queue.in({from, event}, queue)
    dispatch_events(queue, pending_demand, [])
  end

  def handle_call({:notify, _event}, _from, {queue, pending_demand}) do
    {:reply, {:error, :too_many_requests_to_user}, [], {queue, pending_demand}}
  end

  def handle_demand(incoming_demand, {queue, pending_demand}) do
    dispatch_events(queue, incoming_demand + pending_demand, [])
  end

  def handle_info({:reply, _from}, {queue, demand}) do
    dispatch_events(queue, demand, [])
  end

  defp dispatch_events(queue, 0, events) do
    {:noreply, Enum.reverse(events), {queue, 0}}
  end

  defp dispatch_events(queue, demand, events) do
    case :queue.out(queue) do
      {{:value, event}, queue} ->
        dispatch_events(queue, demand - 1, [event | events])

      {:empty, queue} ->
        {:noreply, Enum.reverse(events), {queue, demand}}
    end
  end
end
