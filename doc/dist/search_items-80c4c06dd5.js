searchNodes=[{"doc":"Documentation for ExBanking project.There are the public functions where can be invoked with iex.ExampleFor example you can run the command belowiex&gt; ExBanking.create_user(&quot;Paulo&quot;) :okFor more information you can check the above functions which has some examples.","ref":"ExBanking.html","title":"ExBanking","type":"module"},{"doc":"Create a new user to the given name.Exampleiex&gt; ExBanking.create_user(&quot;John&quot;) :ok","ref":"ExBanking.html#create_user/1","title":"ExBanking.create_user/1","type":"function"},{"doc":"Deposit money amount to the given user with the given currency.Exampleiex&gt; ExBanking.deposit(&quot;John&quot;, 10, &quot;R$&quot;) {:ok, 10} iex&gt; ExBanking.deposit(&quot;John&quot;, 15, &quot;R$&quot;) {:ok, 25}","ref":"ExBanking.html#deposit/3","title":"ExBanking.deposit/3","type":"function"},{"doc":"Get the balence for the given user.Exampleiex&gt; ExBanking.get_balance(&quot;John&quot;, &quot;R$&quot;) {:ok, 25} iex&gt; ExBanking.get_balance(&quot;nonexistent user&quot;, &quot;R$&quot;) {:error, :user_does_not_exist}","ref":"ExBanking.html#get_balance/2","title":"ExBanking.get_balance/2","type":"function"},{"doc":"Transfer money between users.Exampleiex&gt; ExBanking.send(&quot;John&quot;, &quot;Paulo&quot;, 30, &quot;R$&quot;) {:ok, 10, 30}","ref":"ExBanking.html#send/4","title":"ExBanking.send/4","type":"function"},{"doc":"Withdraw money to the given amount, user and currency.Exampleiex&gt; ExBanking.deposit(&quot;John&quot;, 10, &quot;R$&quot;) {:ok, 10} iex&gt; ExBanking.withdraw(&quot;John&quot;, 3, &quot;R$&quot;) {:ok, 7}","ref":"ExBanking.html#withdraw/3","title":"ExBanking.withdraw/3","type":"function"},{"doc":"","ref":"ExBanking.html#t:banking_error/0","title":"ExBanking.banking_error/0","type":"type"},{"doc":"Module implementation for dealing with money amount","ref":"ExBanking.Money.html","title":"ExBanking.Money","type":"module"},{"doc":"Load the money to show to the useriex&gt;ExBanking.Money.load(10000) 100.0 iex&gt;ExBanking.Money.load(2545) 25.45","ref":"ExBanking.Money.html#load/1","title":"ExBanking.Money.load/1","type":"function"},{"doc":"Parse amount to integer coming from user inputiex&gt;ExBanking.Money.parse_to_int(10.459) 1045 iex&gt;ExBanking.Money.parse_to_int(10.05) 1025","ref":"ExBanking.Money.html#parse_to_int/1","title":"ExBanking.Money.parse_to_int/1","type":"function"},{"doc":"User Domain Functions.","ref":"ExBanking.User.html","title":"ExBanking.User","type":"module"},{"doc":"","ref":"ExBanking.User.html#create/1","title":"ExBanking.User.create/1","type":"function"},{"doc":"","ref":"ExBanking.User.html#deposit/3","title":"ExBanking.User.deposit/3","type":"function"},{"doc":"","ref":"ExBanking.User.html#get_balance/2","title":"ExBanking.User.get_balance/2","type":"function"},{"doc":"","ref":"ExBanking.User.html#send/4","title":"ExBanking.User.send/4","type":"function"},{"doc":"","ref":"ExBanking.User.html#withdraw/3","title":"ExBanking.User.withdraw/3","type":"function"},{"doc":"User bucket to store user information","ref":"ExBanking.User.Bucket.html","title":"ExBanking.User.Bucket","type":"module"},{"doc":"Will increase the user money amount with the given amount and currency","ref":"ExBanking.User.Bucket.html#add_amount/3","title":"ExBanking.User.Bucket.add_amount/3","type":"function"},{"doc":"","ref":"ExBanking.User.Bucket.html#add_amount!/3","title":"ExBanking.User.Bucket.add_amount!/3","type":"function"},{"doc":"Returns a specification to start this module under a supervisor.See Supervisor.","ref":"ExBanking.User.Bucket.html#child_spec/1","title":"ExBanking.User.Bucket.child_spec/1","type":"function"},{"doc":"Will decrease the user money amount with the given amount and currency","ref":"ExBanking.User.Bucket.html#decrease_amount/3","title":"ExBanking.User.Bucket.decrease_amount/3","type":"function"},{"doc":"","ref":"ExBanking.User.Bucket.html#decrease_amount!/3","title":"ExBanking.User.Bucket.decrease_amount!/3","type":"function"},{"doc":"Returns the user money amount","ref":"ExBanking.User.Bucket.html#get_amount/2","title":"ExBanking.User.Bucket.get_amount/2","type":"function"},{"doc":"","ref":"ExBanking.User.Bucket.html#get_amount!/2","title":"ExBanking.User.Bucket.get_amount!/2","type":"function"},{"doc":"","ref":"ExBanking.User.Bucket.html#registry_name/1","title":"ExBanking.User.Bucket.registry_name/1","type":"function"},{"doc":"","ref":"ExBanking.User.Bucket.html#start_link/1","title":"ExBanking.User.Bucket.start_link/1","type":"function"},{"doc":"","ref":"ExBanking.User.Bucket.html#update_user_balance/3","title":"ExBanking.User.Bucket.update_user_balance/3","type":"function"},{"doc":"User consumer logic following the GenStage documentation.The events are handled inside the handle_events function.","ref":"ExBanking.User.Consumer.html","title":"ExBanking.User.Consumer","type":"module"},{"doc":"Handle the events from the producer. When finished, reply back to the producer with the event result","ref":"ExBanking.User.Consumer.html#handle_events/3","title":"ExBanking.User.Consumer.handle_events/3","type":"function"},{"doc":"Dynamically init the consumer with the given subscriber","ref":"ExBanking.User.Consumer.html#init/1","title":"ExBanking.User.Consumer.init/1","type":"function"},{"doc":"Name registry for User Consumer","ref":"ExBanking.User.Consumer.html#registry_name/1","title":"ExBanking.User.Consumer.registry_name/1","type":"function"},{"doc":"Starts the user consumer.","ref":"ExBanking.User.Consumer.html#start_link/1","title":"ExBanking.User.Consumer.start_link/1","type":"function"},{"doc":"User producer logic following the GenStage documentation. Here we can call the sync_notify function for passing events to our consumer.Exampleiex&gt; ExBanking.User.Producer.sync_notify({:deposit, %{user: &quot;Paulo&quot;, amount: 2.00, currency: &quot;BRL&quot;}}) 2.0","ref":"ExBanking.User.Producer.html","title":"ExBanking.User.Producer","type":"module"},{"doc":"Handler for the GenStage call function.If the pending_demand is less than zero this handler will reply with an error based on the consumer max_demand. But if this event has a priority, like a rollback in a transaction, the handler will dispatch immediately.","ref":"ExBanking.User.Producer.html#handle_call/3","title":"ExBanking.User.Producer.handle_call/3","type":"function"},{"doc":"Handler for the GenStage demands.It will receive the GenStage demands and dispatch to the event handler. This will increase the demands by adding the incoming demand to the pending demand","ref":"ExBanking.User.Producer.html#handle_demand/2","title":"ExBanking.User.Producer.handle_demand/2","type":"function"},{"doc":"Init the GenStage producer","ref":"ExBanking.User.Producer.html#init/1","title":"ExBanking.User.Producer.init/1","type":"function"},{"doc":"Checks if the user producer exists","ref":"ExBanking.User.Producer.html#registry_exists?/1","title":"ExBanking.User.Producer.registry_exists?/1","type":"function"},{"doc":"Name registry for User Producer","ref":"ExBanking.User.Producer.html#registry_name/1","title":"ExBanking.User.Producer.registry_name/1","type":"function"},{"doc":"Starts the user producer.","ref":"ExBanking.User.Producer.html#start_link/1","title":"ExBanking.User.Producer.start_link/1","type":"function"},{"doc":"Sends an event and returns only after the event is dispatched.","ref":"ExBanking.User.Producer.html#sync_notify/2","title":"ExBanking.User.Producer.sync_notify/2","type":"function"},{"doc":"","ref":"ExBanking.User.Producer.html#t:event/0","title":"ExBanking.User.Producer.event/0","type":"type"},{"doc":"","ref":"ExBanking.User.Producer.EventParam.html","title":"ExBanking.User.Producer.EventParam","type":"module"},{"doc":"","ref":"ExBanking.User.Producer.EventParam.html#t:t/0","title":"ExBanking.User.Producer.EventParam.t/0","type":"type"},{"doc":"User supervisor responsible for starting the user store bucket, producer and consumer.","ref":"ExBanking.User.Supervisor.html","title":"ExBanking.User.Supervisor","type":"module"},{"doc":"Returns a specification to start this module under a supervisor.See Supervisor.","ref":"ExBanking.User.Supervisor.html#child_spec/1","title":"ExBanking.User.Supervisor.child_spec/1","type":"function"},{"doc":"","ref":"ExBanking.User.Supervisor.html#start_link/1","title":"ExBanking.User.Supervisor.start_link/1","type":"function"}]