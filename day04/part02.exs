defmodule Day04Part02 do
  def solve(input) do
    grid =
      input
      |> String.trim()
      |> String.split("\n")
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, row} ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.map(fn {char, col} -> {{row, col}, char} end)
      end)
      |> Map.new()

    remove_all(grid, 0)
  end

  defp remove_all(grid, total_removed) do
    accessible =
      grid
      |> Enum.filter(fn {{row, col}, char} ->
        char == "@" && can_access?(grid, row, col)
      end)
      |> Enum.map(fn {pos, _} -> pos end)

    case accessible do
      [] ->
        total_removed

      positions ->
        new_grid =
          Enum.reduce(positions, grid, fn pos, acc ->
            Map.put(acc, pos, ".")
          end)

        remove_all(new_grid, total_removed + length(positions))
    end
  end

  defp can_access?(grid, row, col) do
    neighbors = [
      {row - 1, col - 1}, {row - 1, col}, {row - 1, col + 1},
      {row, col - 1},                     {row, col + 1},
      {row + 1, col - 1}, {row + 1, col}, {row + 1, col + 1}
    ]

    adjacent_rolls =
      neighbors
      |> Enum.count(fn pos -> Map.get(grid, pos) == "@" end)

    adjacent_rolls < 4
  end
end

input = File.read!("puzzle_inputpart02.txt")
result = Day04Part02.solve(input)
IO.puts("Total rolls removed: #{result}")
