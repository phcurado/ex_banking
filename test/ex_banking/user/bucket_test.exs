defmodule ExBanking.User.BucketTest do
  use ExUnit.Case

  alias ExBanking.User.Bucket

  test "Start Bucket" do
    {:ok, pid} = Bucket.start_link(:bucket)
    assert is_pid(pid)
  end

  test "registry name" do
    assert Bucket.registry_name("Paulo") == {:via, Registry, {Registry.User, "PauloBucket"}}
  end

  test "get_amount/2" do
    Bucket.start_link(Bucket.registry_name("Paulo"))
    assert Bucket.get_amount("Paulo", "R$") == 0.0
  end

  test "add_amount/2" do
    "Paulo"
    |> Bucket.registry_name()
    |> Bucket.start_link()

    assert Bucket.add_amount("Paulo", 10.00, "US") == 10.0
    assert Bucket.get_amount("Paulo", "R$") == 0.0
    assert Bucket.get_amount("Paulo", "US") == 10.0
  end
end
