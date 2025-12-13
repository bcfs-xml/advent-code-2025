defmodule Day07part02 do
  def solve(input) do
    lines = String.split(input, "\n", trim: true)
    grid = parse_grid(lines)

    start_col = find_start(Enum.at(lines, 0))
    max_row = length(lines) - 1
    max_col = String.length(Enum.at(lines, 0)) - 1

    initial_timelines = %{start_col => 1}

    count_timelines(grid, initial_timelines, 1, max_row, max_col)
  end

  defp parse_grid(lines) do
    lines
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, row} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.filter(fn {char, _col} -> char == "^" end)
      |> Enum.map(fn {_char, col} -> {row, col} end)
    end)
    |> MapSet.new()
  end

  defp find_start(first_line) do
    first_line
    |> String.graphemes()
    |> Enum.find_index(fn char -> char == "S" end)
  end

  defp count_timelines(_grid, timelines, row, max_row, _max_col) when row > max_row do
    timelines
    |> Map.values()
    |> Enum.sum()
  end

  defp count_timelines(grid, timelines, row, max_row, max_col) do

    new_timelines =
      timelines
      |> Enum.reduce(%{}, fn {col, count}, acc ->
        if MapSet.member?(grid, {row, col}) do
          left = col - 1
          right = col + 1

          acc = if left >= 0, do: Map.update(acc, left, count, &(&1 + count)), else: acc
          acc = if right <= max_col, do: Map.update(acc, right, count, &(&1 + count)), else: acc
          acc
        else
          # Continue straight
          Map.update(acc, col, count, &(&1 + count))
        end
      end)

    count_timelines(grid, new_timelines, row + 1, max_row, max_col)
  end
end

input = File.read!("puzzle_inputpart02.txt")

result = Day07part02.solve(input)
IO.puts("Total timelines: #{result}")
