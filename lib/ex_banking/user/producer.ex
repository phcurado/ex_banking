defmodule ExBanking.User.Producer do
  use GenStage

  @type event :: {:deposit, %{user: String.t(), amount: number(), currency: String.t()}}

  @doc "Starts the user producer."
  def start_link(name) do
    GenStage.start_link(__MODULE__, :ok, name: name)
  end

  @doc "Sends an event and returns only after the event is dispatched."
  @spec sync_notify(event, :infinity | non_neg_integer) :: event | {:error, :not_found}
  def sync_notify({_, %{user: user}} = event, timeout \\ 5000) do
    case registry_exists?(user) do
      true -> GenStage.call(registry_name(user), {:notify, event}, timeout)
      false -> {:error, :not_found}
    end
  end

  def registry_name(user) do
    {:via, Registry, {Registry.User, user <> "Producer"}}
  end

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

  def handle_call({:notify, event}, from, {queue, pending_demand}) do
    queue = :queue.in({from, event}, queue)
    send(self(), {:reply, from})

    {:noreply, [], {queue, pending_demand - 1}}
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
