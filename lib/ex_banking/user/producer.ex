defmodule ExBanking.User.Producer do
  use GenStage

  @doc "Starts the user producer."
  def start_link(name) do
    GenStage.start_link(__MODULE__, :ok, name: name)
  end

  @doc "Sends an event and returns only after the event is dispatched."
  def sync_notify(name, event, timeout \\ 5000) do
    GenStage.call(registry_name(name), {:notify, event}, timeout)
  end

  def registry_name(user) do
    {:via, Registry, {Registry.User, user <> "Producer"}}
  end

  ## Callbacks

  def init(:ok) do
    {:producer, {:queue.new(), 0}}
  end

  def handle_call({:notify, event}, from, {queue, pending_demand}) do
    queue = :queue.in({from, event}, queue)
    dispatch_events(queue, pending_demand, [])
  end

  def handle_demand(incoming_demand, {queue, pending_demand}) do
    dispatch_events(queue, incoming_demand + pending_demand, [])
  end

  defp dispatch_events(queue, 0, events) do
    {:noreply, Enum.reverse(events), {queue, 0}}
  end

  defp dispatch_events(queue, demand, events) do
    case :queue.out(queue) do
      {{:value, {from, event}}, queue} ->
        GenStage.reply(from, :ok)
        dispatch_events(queue, demand - 1, [event | events])

      {:empty, queue} ->
        {:noreply, Enum.reverse(events), {queue, demand}}
    end
  end
end
