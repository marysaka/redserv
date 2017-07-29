defmodule RedservEx.Encoder do
    def encode(data) when is_list(data), do: "*#{Enum.count(data)}\r\n" <> encode_array(data, "")
    def encode({:simple_str, value}), do: "+" <> value <> "\r\n"
    def encode({:error_str, value}), do: "-" <> value <> "\r\n"
    def encode({:integer, value}), do: ":" <> Integer.to_string(value) <> "\r\n"
    def encode({:bulk_str, nil}), do: "$-1\r\n"
    def encode({:bulk_str, value}), do: "$#{String.length(value)}\r\n#{value}\r\n"
    def encode(_), do: nil

    defp encode_array([head | tail], accumulator), do: encode_array(tail, accumulator <> encode(head))
    defp encode_array([], accumulator), do: accumulator
end