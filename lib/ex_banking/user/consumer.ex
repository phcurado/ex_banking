defmodule ExBanking.User.Consumer do
  use GenStage

  @doc "Starts the user consumer."
  def start_link({consumer_name, subscription}) do
    GenStage.start_link(__MODULE__, {:ok, subscription}, name: consumer_name)
  end

  def registry_name(user) do
    {:via, Registry, {Registry.User, user <> "Consumer"}}
  end

  ## Callbacks

  def init({:ok, subscription}) do
    {:consumer, :ok, subscribe_to: [{subscription, max_demand: 10}]}
  end

  def handle_events(events, _from, state) do
    Process.sleep(1000)
    for event <- events do
      IO.inspect({self(), event})
    end
    {:noreply, [], state}
  end
end
