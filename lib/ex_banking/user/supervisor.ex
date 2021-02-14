defmodule ExBanking.User.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(%{user: user} = args) do
    Supervisor.start_link(__MODULE__, args, name: {:via, Registry, {Registry.User, user}})
  end

  @impl true
  def init(_args) do
    children = [
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
