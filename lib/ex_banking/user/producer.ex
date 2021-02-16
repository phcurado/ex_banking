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
  @type actions :: :deposit | :withdraw
  @type event ::
          {actions, %{user: String.t(), amount: number(), currency: String.t()}}

  @doc "Starts the user producer."
  def start_link(name) do
    GenStage.start_link(__MODULE__, :ok, name: name)
  end

  @doc "Sends an event and returns only after the event is dispatched."
  @spec sync_notify(event | event_balance, :infinity | non_neg_integer) ::
          {:ok, any} | {:error, atom(), atom()}
  def sync_notify(event, timeout \\ 5000)

  def sync_notify({event_type, %{user: user}} = event, timeout) do
    case registry_exists?(user) do
      true -> GenStage.call(registry_name(user), event, timeout)
      false -> {:error, :not_found, event_type}
    end
  end

  def sync_notify(_event, _timeout) do
    {:error, :wrong_arguments}
  end

  @doc "Name registry for User Producer"
  def registry_name(user) do
    {:via, Registry, {Registry.User, user <> "Producer"}}
  end

  @doc "Checks if the user producer exists"
  @spec registry_exists?(user :: String.t()) :: boolean
  def registry_exists?(user) do
    case Registry.lookup(Registry.User, user) do
      [] -> false
      _ -> true
    end
  end

  ## Callbacks

  @doc """
  Init the GenStage producer
  """
  def init(:ok) do
    {:producer, {:queue.new(), 0}, dispatcher: GenStage.BroadcastDispatcher}
  end

  @doc """
  Handler for the GenStage call function.

  If the `pending_demand` is less than zero this handler will reply
  with an error based on the consumer `max_demand`. But if this event has a priority, like a rollback in a transaction,
  the handler will dispatch immediately.
  """
  def handle_call(event, from, {queue, pending_demand}) when pending_demand > 0 do
    queue = :queue.in({from, event}, queue)
    dispatch_events(queue, pending_demand, [])
  end

  def handle_call({_event_type, %{priority: :now}} = event, _from, state) do
    # Dispatch immediately
    {:reply, :ok, [event], state}
  end

  def handle_call({event_type, _}, _from, {queue, pending_demand}) do
    {:reply, {:error, :too_many_requests_to_user, event_type}, [], {queue, pending_demand}}
  end

  @doc """
  Handler for the GenStage demands.

  It will receive the GenStage demands and dispatch to the event handler. This will increase the
  demands by adding the incoming demand to the pending demand
  """
  def handle_demand(incoming_demand, {queue, pending_demand}) do
    dispatch_events(queue, incoming_demand + pending_demand, [])
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
