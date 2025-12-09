defmodule Day05Part02 do
  def solve(input) do
    ranges = parse_ranges(input)

    ranges
    |> merge_ranges()
    |> count_unique_ids()
  end

  defp parse_ranges(input) do
    normalized =
      input
      |> String.replace("\r\n", "\n")
      |> String.trim()

    [ranges_section | _] = String.split(normalized, "\n\n", parts: 2)

    ranges_section
    |> String.split("\n")
    |> Enum.map(&parse_range/1)
  end

  defp parse_range(line) do
    [start_val, end_val] =
      line
      |> String.split("-")
      |> Enum.map(&String.to_integer/1)

    {start_val, end_val}
  end

  defp merge_ranges(ranges) do
    sorted = Enum.sort_by(ranges, fn {start_val, _} -> start_val end)

    Enum.reduce(sorted, [], fn {start_val, end_val}, acc ->
      case acc do
        [] ->
          [{start_val, end_val}]

        [{prev_start, prev_end} | rest] ->
          if start_val <= prev_end + 1 do
            [{prev_start, max(prev_end, end_val)} | rest]
          else
            [{start_val, end_val} | acc]
          end
      end
    end)
  end

  defp count_unique_ids(merged_ranges) do
    merged_ranges
    |> Enum.map(fn {start_val, end_val} -> end_val - start_val + 1 end)
    |> Enum.sum()
  end
end

input = File.read!("puzzle_inputpart02.txt")
result = Day05Part02.solve(input)
IO.puts("Total fresh ingredient IDs: #{result}")
