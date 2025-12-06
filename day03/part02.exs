defmodule Day03Part02 do
  @digits_to_pick 12

  def find_max_joltage(bank) do
    digits = String.graphemes(bank)
    n = length(digits)

    pick_digits(digits, n, @digits_to_pick, 0, [])
    |> Enum.join()
    |> String.to_integer()
  end

  defp pick_digits(_digits, _n, 0, _start, acc), do: Enum.reverse(acc)

  defp pick_digits(digits, n, remaining, start, acc) do
    last_valid = n - remaining

    {best_digit, best_idx} =
      start..last_valid
      |> Enum.map(fn i -> {Enum.at(digits, i), i} end)
      |> Enum.max_by(fn {digit, _idx} -> digit end)

    pick_digits(digits, n, remaining - 1, best_idx + 1, [best_digit | acc])
  end

  def solve(input) do
    input
    |> String.trim()
    |> String.replace("\r", "")
    |> String.split("\n")
    |> Enum.map(&find_max_joltage/1)
    |> Enum.sum()
  end
end

# Test with example
example = """
987654321111111
811111111111119
234234234234278
818181911112111
"""

IO.puts("Teste com exemplo:")

example
|> String.trim()
|> String.replace("\r", "")
|> String.split("\n")

IO.puts("  Total esperado: 3121910778619")
IO.puts("  Total calculado: #{Day03Part02.solve(example)}")
IO.puts("")

# Solve real puzzle
puzzle_input = File.read!("puzzle_inputpart01.txt")
result = Day03Part02.solve(puzzle_input)
IO.puts("Resposta do puzzle: #{result}")
