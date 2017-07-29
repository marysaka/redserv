defmodule RedservEx.Protocol do
  use GenServer
  import RedservEx.Dispatcher.Utils

  @behaviour :ranch_protocol

  def start_link(ref, socket, transport, _opts) do
    pid = :proc_lib.spawn_link(__MODULE__, :init, [ref, socket, transport])
    {:ok, pid}
  end

  def init(ref, socket, transport) do
    IO.puts "> New client"

    :ok = :ranch.accept_ack(ref)
    :ok = transport.setopts(socket, [{:active, true}])
    :gen_server.enter_loop(__MODULE__, [], %{socket: socket, transport: transport, pub_sub: false})
  end

  def handle_info({:tcp, socket, data}, state = %{socket: socket, transport: transport, pub_sub: false}) do
    {:noreply, RedservEx.Dispatcher.Command.receive_command(state, transport, socket, data)}
  end

  def handle_info({:tcp, socket, _data}, state = %{socket: socket, transport: transport, pub_sub: true}) do
    send_error(socket, transport, "No PUB/SUB NOPE")
    {:noreply, state}
  end

  def handle_info({:tcp_closed, socket}, state = %{socket: socket, transport: transport}) do
    if (state.pub_sub == true) do
      RedservEx.PubSub.exit_ps()
    end
    transport.close(socket)
    {:stop, :normal, state}
  end

  def handle_cast({:publish, channel, message}, state = %{socket: socket, transport: transport}) do
    send_data(socket, transport, [{:bulk_str, "message"}, {:bulk_str, channel}, {:bulk_str, message}])
    {:noreply, state}
  end
end