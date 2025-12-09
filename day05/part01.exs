defmodule Day05Part01 do
  def solve(input) do
    {ranges, ingredients} = parse_input(input)

    ingredients
    |> Enum.count(fn id -> is_fresh?(id, ranges) end)
  end

  defp parse_input(input) do
    # Normaliza line endings e split por linha em branco
    normalized =
      input
      |> String.replace("\r\n", "\n")
      |> String.trim()

    [ranges_section, ingredients_section] =
      String.split(normalized, "\n\n", parts: 2)

    ranges =
      ranges_section
      |> String.split("\n")
      |> Enum.map(&parse_range/1)

    ingredients =
      ingredients_section
      |> String.split("\n")
      |> Enum.filter(&(&1 != ""))
      |> Enum.map(&String.to_integer/1)

    {ranges, ingredients}
  end

  defp parse_range(line) do
    [start_val, end_val] =
      line
      |> String.split("-")
      |> Enum.map(&String.to_integer/1)

    {start_val, end_val}
  end

  defp is_fresh?(id, ranges) do
    Enum.any?(ranges, fn {start_val, end_val} ->
      id >= start_val and id <= end_val
    end)
  end
end

input = File.read!("puzzle_inputpart01.txt")
result = Day05Part01.solve(input)
IO.puts("fresh ingredients: #{result}")
