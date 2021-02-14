defmodule ExBanking.User.Supervisor do
  @moduledoc false

  use Supervisor

  alias ExBanking.User.{Producer, Consumer}

  def start_link(%{user: user} = args) do
    Supervisor.start_link(__MODULE__, args, name: {:via, Registry, {Registry.User, user}})
  end

  @impl true
  def init(%{user: user}) do
    children = [
      {Producer, Producer.registry_name(user)},
      {Consumer, {Consumer.registry_name(user), Producer.registry_name(user)}}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
