defmodule ExBanking.User.ProducerTest do
  use ExUnit.Case

  alias ExBanking.User.Producer

  test "Start GenStage" do
    {:ok, pid} = GenStage.start_link(Producer, :ok)
    assert is_pid(pid)
  end

  test "Subscribe to producer" do
    {:ok, producer} = GenStage.start_link(Producer, :ok)

    defmodule GenStageConsumer do
      use GenStage

      def start_link(_) do
        GenStage.start_link(__MODULE__, :ok)
      end

      def init(:ok) do
        {:consumer, :ok}
      end
    end

    {:ok, consumer} = GenStage.start_link(GenStageConsumer, :ok)

    {:ok, reference} = GenStage.sync_subscribe(consumer, to: producer)
    assert is_reference(reference)
  end

  test "Returns error when passing the wrong arguments" do
    assert Producer.sync_notify({:event}) == {:error, :wrong_arguments}
  end

  test "Returns not found when the user does not exists" do
    assert Producer.sync_notify(
             {:deposit, %{user: "Random user", amount: 10.00, currency: "USD"}}
           ) == {:error, :not_found, :deposit}
  end
end
