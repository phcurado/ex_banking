# ExBanking

OTP application in Elixir language. This small project aims to solve [this](https://coingaming.github.io/elixir-test/) challenge from [coingaming](https://coingaming.io/).

## Installation and Running

- Install dependencies with `mix deps.get`
- Start the project with in the interactive shell with `iex -S mix`


## Architecture

Following Elxir patterns, this project was divided into a main module with the project name (`ExBanking`) and internal modules to implement the domain logic.

### ExBanking
This is the presentation module where are the public functions described in this challenge. Here the functions are delegated to a internal module which contains the domain implementations.


### ExBanking.User
This is where lives the implementation of the `ExBanking` functions. It contains some logic for calling other internal modules with some OTP implemetations and returning the right errors/responses for the public api.

### ExBanking.User.Bucket
Where is stored each user information (map of money amount and currency). Implemented with [Agent](https://hexdocs.pm/elixir/Agent.html) in which the main use case is for state managment.

### ExBanking.User.Producer and ExBanking.User.Consumer

Both of this modules use the [GenStage](https://hexdocs.pm/gen_stage/GenStage.html) implementation for making every request to a specific user act like a producer/consumer. These way we can handle concurrent access to the user bucket by doing the actions sequentially.

### ExBanking.User.Supervisor
Each user will have their own `Bucket`, `Consumer` and `Producer`. The [Supervisor](https://hexdocs.pm/elixir/Supervisor.html) aims to guarantee the liveness of these services. 


## API Documentation

To generate the api documentation, follow the [ex_docs](https://github.com/elixir-lang/ex_doc) instructions to install ExDoc as an escript. Then run the following command:

```shell
ex_doc "ExBanking" "0.1.0" "_build/dev/lib/ex_banking/ebin"   
```

## Final thoughts