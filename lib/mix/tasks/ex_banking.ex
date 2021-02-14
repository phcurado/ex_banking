defmodule Mix.Tasks.ExBanking do
  use Mix.Task

  @shortdoc "Prints ExBanking help information"

  @moduledoc """
  Prints ExBanking tasks and their information.
      mix ex_banking
  """

  @doc false
  def run(args) do
    {_opts, args} = OptionParser.parse!(args, strict: [])

    case args do
      [] -> general()
      _ -> Mix.raise "Invalid arguments, expected: mix ex_banking"
    end
  end

  defp general() do
    Application.ensure_all_started(:ex_banking)
    Mix.shell().info "ExBanking v#{Application.spec(:ex_banking, :vsn)}"
    Mix.shell().info "Project for coingaming."
    Mix.shell().info "\nAvailable tasks:\n"
    Mix.Tasks.Help.run(["--search", "ex_banking."])
  end
end
