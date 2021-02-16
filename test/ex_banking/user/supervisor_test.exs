defmodule ExBanking.User.SupervisorTest do
  use ExUnit.Case

  test "Start supervisor" do
    {:ok, pid} = ExBanking.User.Supervisor.start_link(%{user: "newSupervisor"})

    assert is_pid(pid)
  end
end
