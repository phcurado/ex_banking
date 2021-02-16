defmodule ExBanking.User.ProducerTest do
  use ExUnit.Case

  alias ExBanking.User.Producer
  alias ExBanking.User.Producer.EventParam

  defmodule GenStageConsumer do
    use GenStage

    def start_link() do
      GenStage.start_link(__MODULE__, :ok)
    end

    def init(:ok) do
      {:consumer, :ok}
    end

    def handle_events(events, _from, state) do
      for {from, _} <- events do
        GenStage.reply(from, :ok)
      end

      {:noreply, [], state}
    end
  end

  test "Start GenStage" do
    {:ok, pid} = Producer.start_link(:testing_producer)
    assert is_pid(pid)
  end

  test "Subscribe to producer" do
    {:ok, producer} = Producer.start_link(:testing_producer)
    {:ok, consumer} = GenStageConsumer.start_link()
    {:ok, reference} = GenStage.sync_subscribe(consumer, to: producer)
    assert is_reference(reference)
  end

  test "returns :too_many_requests_to_user when demand reaches zero" do
    {:ok, producer} =
      "ProducerTestUser"
      |> Producer.registry_name()
      |> Producer.start_link()

    {:ok, consumer} = GenStageConsumer.start_link()

    GenStage.sync_subscribe(consumer, to: producer, max_demand: 1)

    result =
      [
        %EventParam{user: "ProducerTestUser", currency: "EUR"},
        %EventParam{user: "ProducerTestUser", currency: "EUR"},
        %EventParam{user: "ProducerTestUser", currency: "US"},
        %EventParam{user: "ProducerTestUser", currency: "US"},
        %EventParam{user: "ProducerTestUser", currency: "US"}
      ]
      |> Enum.map(fn event ->
        Task.async(fn -> Producer.sync_notify({:get_balance, event}) end)
      end)
      |> Task.await_many()
      |> Enum.count(fn res -> res == :ok end)

    # max_demand set to 1
    assert result == 1
  end

  test "Returns error when passing the wrong arguments" do
    assert Producer.sync_notify({:event}) == {:error, :wrong_arguments}
  end

  test "Returns not found when the user does not exists" do
    assert Producer.sync_notify(
             {:deposit, %EventParam{user: "Random user", amount: 10.00, currency: "USD"}}
           ) == {:error, :not_found, :deposit}
  end
end
