defmodule RedservEx.PubSub do
    use GenServer

    def start_link do
         GenServer.start_link(__MODULE__, %{subscribe: %{}}, [name: __MODULE__])        
    end

    def init(state) do
        {:ok, state}
    end

    def enter_ps(), do: GenServer.call(RedservEx.PubSub, {:enter_ps})

    def exit_ps(), do: GenServer.call(RedservEx.PubSub, {:exit_ps})

    def register(list) do
        GenServer.call(RedservEx.PubSub, {:register, list})
    end

    def unregister(list) do
        GenServer.call(RedservEx.PubSub, {:unregister, list})
    end

    def publish(channel, message) do
        GenServer.call(RedservEx.PubSub, {:publish, channel, message})
    end

    def handle_call({:enter_ps},_, state) do
        {:reply, :ok, state}
    end

    def handle_call({:exit_ps},_, state) do
        {:reply, :ok, state}
    end

    def handle_call({:register, list}, {pid,_}, state) do
        state = register_client(list, pid, state)
        {:reply, list, state}
    end

    def handle_call({:unregister, []}, from, state) do
        handle_call({:unregister, state.subscribe |> Map.keys}, from, state)
    end

    def handle_call({:unregister, list}, {pid,_}, state) do
        state = unregister_client(list, pid, state)
        {:reply, list, state}
    end

    def handle_call({:publish, channel, message},_, state) do
        listeners = (state.subscribe[channel] || [])
        listeners |> Enum.each(fn (pid) -> GenServer.cast(pid, {:publish, channel, message}) end)
        {:reply, Enum.count(listeners), state}
    end

    def handle_call(params, from, state) do
        super(params, from, state)
    end

    def register_client([head | tail], from, state) do
        data = ((state.subscribe[head] || []) ++ [from]) |> Enum.uniq
        subscribe = state.subscribe |> put_in([head], data)
        register_client(tail, from, %{state | subscribe: subscribe})
    end

    def register_client([],_, state), do: state

    def unregister_client([head | tail], from, state) do
        data = ((state.subscribe[head] || []) -- [from]) |> Enum.uniq
        subscribe = state.subscribe |> put_in([head], data)
        unregister_client(tail, from, %{state | subscribe: subscribe})
    end

    def unregister_client([],_, state), do: state
end