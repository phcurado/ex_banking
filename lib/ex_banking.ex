defmodule ExBanking do
  @moduledoc """
  Documentation for `ExBanking` project.

  There are the public functions where can be invoked with `iex`.

  ## Example
  For example you can run the command below
      iex> ExBanking.create_user("Paulo")
      :ok

  For more information you can check the above functions which has some examples.
  """

  @type banking_error ::
          {:error,
           :wrong_arguments
           | :user_already_exists
           | :user_does_not_exist
           | :not_enough_money
           | :sender_does_not_exist
           | :receiver_does_not_exist
           | :too_many_requests_to_user
           | :too_many_requests_to_sender
           | :too_many_requests_to_receiver}

  @doc """
  Create a new user to the given `name`.

  ## Example
      iex> ExBanking.create_user("John")
      :ok
  """
  @spec create_user(user :: String.t()) :: :ok | banking_error
  defdelegate create_user(user), to: ExBanking.User, as: :create

  @doc """
  Deposit money amount to the given `user` with the given `currency`.

  ## Example
      iex> ExBanking.deposit("John", 10, "R$")
      {:ok, 10}
      iex> ExBanking.deposit("John", 15, "R$")
      {:ok, 25}
  """
  @spec deposit(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number} | banking_error
  defdelegate deposit(user, amount, currency), to: ExBanking.User

  @doc """
  Withdraw money to the given `amount`, `user` and `currency`.

  ## Example
      iex> ExBanking.deposit("John", 10, "R$")
      {:ok, 10}
      iex> ExBanking.withdraw("John", 3, "R$")
      {:ok, 7}
  """
  @spec withdraw(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number} | banking_error
  defdelegate withdraw(user, amount, currency), to: ExBanking.User

  @doc """
  Get the balence for the given `user`.

  ## Example
      iex> ExBanking.get_balance("John", "R$")
      {:ok, 25}
      iex> ExBanking.get_balance("nonexistent user", "R$")
      {:error, :user_does_not_exist}
  """
  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:ok, balance :: number} | banking_error
  defdelegate get_balance(user, currency), to: ExBanking.User

  @doc """
  Transfer money between users.

  ## Example
      iex> ExBanking.send("John", "Paulo", 30, "R$")
      {:ok, 10, 30}
  """
  @spec send(
          from_user :: String.t(),
          to_user :: String.t(),
          amount :: number,
          currency :: String.t()
        ) :: {:ok, from_user_balance :: number, to_user_balance :: number} | banking_error
  defdelegate send(from_user, to_user, amount, currency), to: ExBanking.User
end
