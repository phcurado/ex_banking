# ExBanking

Simple Banking OTP application in Elixir language.

## Installation and Running

- Install dependencies with `mix deps.get`
- Start the project with the interactive shell with `iex -S mix`
- Call the internal functions for testing:
    ```Elixir
    # Create a new user
    iex>ExBanking.create_user("Ralph")
    :ok

    # Deposit money for this user
    iex>ExBanking.deposit("Ralph", 20, "USD")
    {:ok, 20.0}
    ```

## Tests

- Run tests with `mix test`.
- For coverage report, just run `mix test --cover`

```shell
Percentage | Module
-----------|--------------------------
    87.50% | ExBanking.User
   100.00% | ExBanking
   100.00% | ExBanking.Application
   100.00% | ExBanking.Money
   100.00% | ExBanking.User.Bucket
   100.00% | ExBanking.User.Consumer
   100.00% | ExBanking.User.Producer
   100.00% | ExBanking.User.Producer.EventParam
   100.00% | ExBanking.User.Supervisor
-----------|--------------------------
    98.59% | Total
```

## Architecture

Following Elixir patterns, this project was divided into a main module with the project name (`ExBanking`) and internal modules to implement the domain logic.

For the OTP architecture, see the diagram below.

![Architecture diagram](images/applicationdiagram.png?raw=true "Architecture diagram")

### ExBanking

This is the presentation module where are the public functions described in this challenge. Here the functions are delegated to a internal module which contains the domain implementations.


### ExBanking.Money

Module for dealing with money when receiving user's input and showing the amount stored for each user.

### ExBanking.User

This is where lives the implementation of the `ExBanking` functions. It contains some logic for calling other internal modules with some OTP implemetations and returning the right errors/responses for the public api.

### ExBanking.User.Bucket

Where is stored each user information (map of money amount and currency). Implemented with [Agent](https://hexdocs.pm/elixir/Agent.html) which the main use case is for state managment.

### ExBanking.User.Producer and ExBanking.User.Consumer

Both of this modules use the [GenStage](https://hexdocs.pm/gen_stage/GenStage.html) implementation for making every request to a specific user act like a producer/consumer. These way we can handle concurrent access to the user bucket by doing the actions sequentially.

### ExBanking.User.Supervisor

Each user will have their own `Bucket`, `Consumer` and `Producer`. The [Supervisor](https://hexdocs.pm/elixir/Supervisor.html) aims to guarantee the liveness of these services.


## API Documentation

To generate the api documentation, follow the [ex_docs](https://github.com/elixir-lang/ex_doc) instructions to install ExDoc as an escript. Then run the following command:

```shell
ex_doc "ExBanking" "0.1.0" "_build/dev/lib/ex_banking/ebin"   
```

The docs generated was committed to this repository to help the visualization of this project api, It is inside the `doc` folder.

## Final thoughts

Just some thoughts I had when I started doing this project.
### Performance

For dealing with performance, each user created by the public function has their own process made with a Dynamic Supervisor. This way the user has his own Bucket and a way for dealing with multiple requests with the Producer and Consumer. The reason behind this decision was to mitigate concurrency problems on which a user request can affect other users requests.

### Money

For dealing with user money amount input, a helper function as created on the `Money` module for rounding down the user input.
The rounding was very basic, for example:

```Elixir
# For dealing with user input, the value passed is converted to integer with two decimal places
iex>ExBanking.Money.parse_to_int(10.555555)
1055

# Then to load the money to show to the user
iex>ExBanking.Money.load(1055)
10.55
```

### Registry

Was used the [Registry](https://hexdocs.pm/elixir/Registry.html) with unique keys for lookup process names. The purpose of its use was to facilitate the naming convention for processes associated with the user
### GenStage

For the Producer/Consumer, I decided to use `GenStage` because the library has some practical conveniences for dealing with these types of operations. One of then is the `max_demand` flag where I can limit the max process in the user's queue. Another one is the queue itself, which was a perfect fit for solving this problem.

### Agent

For the user `Bucket` I decided to use the `Agent`, according to [documentation](https://hexdocs.pm/elixir/Agent.html), is a abstraction around state with a very basic server implementation.

### Why not just GenServer?

I could have used only `GenServers` to solve this problems, making each user have their own when spawning them with the `DynamicSupervisor`, but I think with a more complete solution using more `OTP` features could benefit this small project. The great advantage of the `Elixir` is having a good ecosystem and great libraries like `GenStage`, which can leverage complex problems with simpler solutions.