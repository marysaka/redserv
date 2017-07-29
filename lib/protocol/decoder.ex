defmodule RedservEx.Decoder do

  def decode(<<"*", elem_count :: binary-size(1), "\r\n", rest :: binary>>) do
    elem_count = elem_count |> String.to_integer
    decode_array(rest, elem_count, [])
  end

  def decode(<<"+", rest :: binary>>), do: decode_simple_string(rest)
  def decode(<<"-", rest :: binary>>), do: decode_error_string(rest)
  def decode(<<"$", rest :: binary>>) do
    decode_bulk_string(rest)
  end
  def decode(<<":", rest :: binary>>), do: decode_integer_string(rest)
  def decode(resp), do: {:error, "Cannot be parsed!", resp}

  defp decode_simple_string(rest) do
    {end_pos,_} = :binary.match(rest, "\r\n")
    <<str :: binary-size(end_pos), "\r\n", rest :: binary>> = rest
    {:simple_str, str, rest}
  end

  defp decode_error_string(rest), do: decode_simple_string(rest) |> put_elem(0, :error_str)

  defp decode_integer_string(rest) do
    {_, value, rest} = decode_simple_string(rest)
    {:integer, value |> String.to_integer, rest}
  end

  defp decode_bulk_string(rest) do
    {end_pos,_} = :binary.match(rest, "\r\n")
    <<size :: binary-size(end_pos), "\r\n", rest :: binary>> = rest
    size = size |> String.to_integer
    {str, rest} = case size do
      -1 -> {nil, rest}
      size ->
        <<str :: binary-size(size), "\r\n", rest :: binary>> = rest
        {str, rest}
    end

    {:bulk_str, str, rest}
  end

#    defp decode_bulk_string(count, rest) do
#       
#        {:bulk_str, bulk, rest}
#    end

  defp decode_array(_, 0, accumulator), do: accumulator

  defp decode_array(raw, count, accumulator) do
    {type, value, raw} = decode(raw)
    decode_array(raw, count - 1, accumulator ++ [{type, value}])
  end
end