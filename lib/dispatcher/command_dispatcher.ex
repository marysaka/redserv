defmodule RedservEx.Dispatcher.Command do
    import RedservEx.Dispatcher.Utils
    def receive_command(state, transport, socket, raw_data) do
        data = RedservEx.Decoder.decode(raw_data) |> lower_command_name
        {type, res, state} = case RedservEx.Command.execute(state, data) do
            {:error, error, state} -> {:error_str, error, state}
            {:ok, str, state} -> {:simple_str, str, state}
            data -> data
        end
        send_data(socket, transport, {type, res})
        state
    end

    defp lower_command_name([{:bulk_str, command} | hd]) do
        [bulk_str: String.downcase(command)] ++ hd
    end
end