defmodule ExBanking.User do
  @moduledoc """
  User Domain.
  """

  def create(user) do
    ExBanking.User.Server.create_user(user)
  end
end
