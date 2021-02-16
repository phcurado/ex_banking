defmodule ExBanking.User.Consumer do
  @moduledoc """
  User consumer logic following the `GenStage` documentation.
  """

  use GenStage

  alias ExBanking.User.Bucket

  @doc "Starts the user consumer."
  def start_link({consumer_name, subscription}) do
    GenStage.start_link(__MODULE__, {:ok, subscription}, name: consumer_name)
  end

  @doc "Name registry for User Consumer"
  def registry_name(user) do
    {:via, Registry, {Registry.User, user <> "Consumer"}}
  end

  ## Callbacks

  @doc "Dynamically init the consumer with the given subscriber"
  def init({:ok, subscription}) do
    {:consumer, :ok, subscribe_to: [{subscription, max_demand: 10}]}
  end

  def handle_events(events, _from, state) do
    for {from, {operation, params}} <- events do
      result = handle_event(operation, params)
      GenStage.reply(from, result)
    end

    {:noreply, [], state}
  end

  def handle_event(:get_balance, %{user: user, currency: currency}) do
    Bucket.get_amount(user, currency)
    |> event_response(:get_balance)
  end

  def handle_event(:deposit, %{user: user, amount: amount, currency: currency}) do
    Bucket.add_amount(user, amount, currency)
    |> event_response(:deposit)
  end

  def handle_event(:withdraw, %{user: user, amount: amount, currency: currency}) do
    Bucket.decrease_amount(user, amount, currency)
    |> event_response(:withdraw)
  end

  defp event_response(response, event) do
    case response do
      {:error, error} -> {:error, error, event}
      resp -> {:ok, resp}
    end
  end
end
