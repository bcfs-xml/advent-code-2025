defmodule Day09Part01 do
  def solve(input) do
    input
    |> parse_coordinates()
    |> find_max_rectangle_area()
  end

  defp parse_coordinates(input) do
    input
    |> String.trim()
    |> String.replace("\r", "")
    |> String.split("\n")
    |> Enum.map(fn line ->
      [x, y] = String.split(line, ",")
      {String.to_integer(x), String.to_integer(y)}
    end)
  end

  defp find_max_rectangle_area(coords) do
    coords
    |> pairs()
    |> Enum.map(fn {{x1, y1}, {x2, y2}} ->
      (abs(x2 - x1) + 1) * (abs(y2 - y1) + 1)
    end)
    |> Enum.max()
  end

  defp pairs(list) do
    for {a, i} <- Enum.with_index(list),
        {b, j} <- Enum.with_index(list),
        i < j,
        do: {a, b}
  end
end

input = File.read!("puzzle_inputpart01.txt")
result = Day09Part01.solve(input)
IO.puts("Largest rectangle area: #{result}")
