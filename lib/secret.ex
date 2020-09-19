defmodule Secret do
  use GenServer

  def start_link(agent_name) do
    name = via(agent_name)
    GenServer.start_link(__MODULE__, agent_name, name: name)
  end

  def echo(server, text) do
    GenServer.call(via(server), {:echo, text})
  end

  def init(name) do
    {:ok, name}
  end

  def handle_call({:echo, text}, _from , name) do
    {:reply, "#{name} says #{text}", name}
  end

  def via(name) do
    {:via, Registry, { Secret.Registry, name}}
  end
end



######
# When we use {:ok, bond_id} =  GenServer.start_link(:bond)
# We can call `echo` callback with `Secret.echo(bond_id)`
# But to note we can also `echo` with `Secret.echo(Secret)` i.e by Module name.
# Reason: because we are creating GenServer with name as per module name in third parameter of GenServer.start_link i.e name: __MODULE__
# It already creates the Process with that name and if we create another GenServer process with it, it will throw error
# {:error, {:already_started, #PID<0.155.0>}}
# We can confirm this by checking process `Process.whereis(Secret)`
# Solution: We can register the name by using `agent_name` i.e GenServer.start_link(__MODULE__, agent_name, name: agent_name)

# There is one issue with this approach, we cannot register Process with string name.
# E.g Secret.start_link("james").It will throw error.
###** (ArgumentError) expected :name option to be one of the following:
#  * nil
#  * atom
#  * {:global, term}  # This Registers the global process. The `term` will be in a global process.
#  * {:via, module, term} #This we are going to implement.
#  Got: "james"
#####


##### via tuple Explanation ######
# Custom implementation to Register process is using `via` tuple. i.e {:via, module, term}
# Use the registry and use the via tuple to actually point to a Registry.
# First thing is to specify name of the registry in this via tuple.
# As we can see in application.ex file there are children specified for the application Supervisor.
# Here we will specify Registry as one of the children.
# We will add following code as children.
# childrens: [
# {Registry, keys: :unique, name: Secret.Registry}
#]
# Add call it as follows:
# {:via, Registry, { Secret.Registry, name}}



### Extra notes:
# To stop Supervisro: `Supervisor.stop(Secret.Supervisor)`   ---> Secret.Supervisor is as per name defined in application.ex
# To start Supervisor: `Secret.Application.start(Secret.Supervisor, [])`
