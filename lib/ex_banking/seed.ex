defmodule ExBanking.Seed do
  def run() do
    ExBanking.create_user("John")
    ExBanking.create_user("Paulo")
    ExBanking.create_user("Aline")
    :ok
  end
end
