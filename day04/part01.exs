defmodule Day04Part01 do
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

    grid
    |> Enum.count(fn {{row, col}, char} ->
      char == "@" && can_access?(grid, row, col)
    end)
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

input = File.read!("puzzle_inputpart01.txt")
result = Day04Part01.solve(input)
IO.puts("Accessible rolls: #{result}")
