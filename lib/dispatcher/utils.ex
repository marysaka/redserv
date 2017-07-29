defmodule RedservEx.Dispatcher.Utils do
  def send_error(socket, transport, message), do: send_data(socket, transport, {:error_str, message})
  def send_simple_string(socket, transport, message), do: send_data(socket, transport, {:simple_str, message})
  def send_integer(socket, transport, integer), do: send_data(socket, transport, {:integer, integer})
  def send_array(socket, transport, array), do: send_data(socket, transport, array)

  
  def send_data(socket, transport, {:raw, str}) when is_bitstring(str) do
    transport.send(socket, str)
  end

  def send_data(socket, transport, preformated) do
    transport.send(socket, RedservEx.Encoder.encode(preformated))
  end
end