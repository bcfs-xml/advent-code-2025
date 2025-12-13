defmodule Day07part01 do
  def solve(input) do
    lines = String.split(input, "\n", trim: true)
    grid = parse_grid(lines)

    start_col = find_start(Enum.at(lines, 0))
    max_row = length(lines) - 1
    max_col = String.length(Enum.at(lines, 0)) - 1

    initial_beams = MapSet.new([start_col])

    count_splits(grid, initial_beams, 1, max_row, max_col, 0)
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

  defp count_splits(_grid, _beams, row, max_row, _max_col, splits) when row > max_row do
    splits
  end

  defp count_splits(grid, beams, row, max_row, max_col, splits) do

    {new_beams, new_splits} =
      beams
      |> Enum.reduce({MapSet.new(), 0}, fn col, {acc_beams, acc_splits} ->
        if MapSet.member?(grid, {row, col}) do
          left = col - 1
          right = col + 1

          new_acc = acc_beams
          new_acc = if left >= 0, do: MapSet.put(new_acc, left), else: new_acc
          new_acc = if right <= max_col, do: MapSet.put(new_acc, right), else: new_acc

          {new_acc, acc_splits + 1}
        else
          {MapSet.put(acc_beams, col), acc_splits}
        end
      end)

    count_splits(grid, new_beams, row + 1, max_row, max_col, splits + new_splits)
  end
end

input = File.read!("puzzle_inputpart01.txt")

result = Day07part01.solve(input)
IO.puts("Total splits: #{result}")
