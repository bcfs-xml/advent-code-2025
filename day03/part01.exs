defmodule Day03 do
  def find_max_joltage(bank) do
    digits = String.graphemes(bank)

    for {d1, i} <- Enum.with_index(digits),
        {d2, j} <- Enum.with_index(digits),
        j > i do
      String.to_integer(d1 <> d2)
    end
    |> Enum.max()
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

# Teste com exemplo
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

IO.puts("  Total esperado: 357")
IO.puts("  Total calculado: #{Day03.solve(example)}")
IO.puts("")

# Resolve o puzzle real
puzzle_input = File.read!("puzzle_inputpart01.txt")
result = Day03.solve(puzzle_input)
IO.puts("Resposta do puzzle: #{result}")
