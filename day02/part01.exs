defmodule Day02Part01 do

  def solve(input) do
    input
    |> parse_ranges()
    |> Enum.flat_map(&find_invalid_ids_in_range/1)
    |> Enum.sum()
  end

  defp parse_ranges(input) do
    input
    |> String.trim()
    |> String.split(",", trim: true)
    |> Enum.map(fn range_str ->
      [start, finish] =
        range_str
        |> String.trim()
        |> String.split("-")
        |> Enum.map(&String.to_integer/1)

      {start, finish}
    end)
  end

  defp find_invalid_ids_in_range({start, finish}) do
    start..finish
    |> Enum.filter(&is_invalid_id?/1)
  end

  defp is_invalid_id?(number) do
    digits = Integer.to_string(number)
    len = String.length(digits)

    rem(len, 2) == 0 and is_repeated_sequence?(digits)
  end

  defp is_repeated_sequence?(digits) do
    half_len = div(String.length(digits), 2)
    {first_half, second_half} = String.split_at(digits, half_len)
    first_half == second_half
  end
end

input = File.read!("pluzze_input_part01.txt")
result = Day02Part01.solve(input)
IO.puts("Sum of all invalid IDs: #{result}")
