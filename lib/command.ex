defmodule RedservEx.Command do
    def execute(state, [{:bulk_str, "publish"}, {:bulk_str, channel}, {:bulk_str, message}]) do
        res = RedservEx.PubSub.publish(channel, message)
        {:integer, res, state}
    end

    def execute(state, [{:bulk_str, "subscribe"} | hd]) do
        RedservEx.PubSub.enter_ps()
        res = RedservEx.PubSub.register(hd |> Enum.map(fn {_,value} -> value end))
        res = for i <- 0..(Enum.count(res) - 1) do
             RedservEx.Encoder.encode([{:bulk_str, "subscribe"}, {:bulk_str, Enum.at(res, i)}, {:integer, i + 1}])
        end |> Enum.join
        {:raw, res, state |> put_in([:pub_sub], true)}
    end

    def execute(state, [{:bulk_str, "unsubscribe"} | hd]) do
        RedservEx.PubSub.enter_ps()
        res = RedservEx.PubSub.register(hd |> Enum.map(fn {_,value} -> value end))
        res = for i <- 0..(Enum.count(res) - 1) do
             RedservEx.Encoder.encode([{:bulk_str, "unsubscribe"}, {:bulk_str, Enum.at(res, i)}, {:integer, i + 1}])
        end |> Enum.join
        {:raw, res, state}
    end

    def execute(state, data) do
        {:error, "Unknown command", state}
    end
end