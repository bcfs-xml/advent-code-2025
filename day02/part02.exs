defmodule Day02Part02 do

  def solve(input) do
    input
    |> parse_ranges()
    |> Enum.flat_map(&find_invalid_ids_in_range/1)
    |> Enum.uniq()
    |> Enum.sum()
  end

  def parse_ranges(input) do
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

  def find_invalid_ids_in_range({start, finish}) do
    start..finish
    |> Enum.filter(&is_invalid_id?/1)
  end

  defp is_invalid_id?(number) do
    digits = Integer.to_string(number)
    len = String.length(digits)
    max_pattern_len = div(len, 2)

    if max_pattern_len < 1 do
      false
    else

      Enum.any?(1..max_pattern_len//1, fn pattern_len ->
        repetitions = div(len, pattern_len)
        rem(len, pattern_len) == 0 and repetitions >= 2 and is_repeated_pattern?(digits, pattern_len)
      end)
    end
  end

  defp is_repeated_pattern?(digits, pattern_len) do
    pattern = String.slice(digits, 0, pattern_len)
    repetitions = div(String.length(digits), pattern_len)


    expected = String.duplicate(pattern, repetitions)
    digits == expected
  end
end


input = File.read!("pluzze_input_part02.txt")
result = Day02Part02.solve(input)
IO.puts("Sum of all invalid IDs: #{result}")
