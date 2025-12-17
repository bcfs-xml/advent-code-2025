defmodule Day10Part01 do
  import Bitwise

  def solve(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_line/1)
    |> Enum.map(&find_min_presses/1)
    |> Enum.sum()
  end

  defp parse_line(line) do
    [_, target_str] = Regex.run(~r/\[([.#]+)\]/, line)
    target = parse_lights(target_str)

    buttons =
      Regex.scan(~r/\(([0-9,]+)\)/, line)
      |> Enum.map(fn [_, indices_str] ->
        indices_str
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
      end)

    num_lights = String.length(target_str)
    {target, buttons, num_lights}
  end

  defp parse_lights(str) do
    str
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {char, idx}, acc ->
      if char == "#" do
        acc ||| (1 <<< idx)
      else
        acc
      end
    end)
  end

  defp find_min_presses({target, buttons, _num_lights}) do
    num_buttons = length(buttons)

    button_masks =
      buttons
      |> Enum.map(fn indices ->
        Enum.reduce(indices, 0, fn idx, acc -> acc ||| (1 <<< idx) end)
      end)

    max_combo = 1 <<< num_buttons

    0..(max_combo - 1)
    |> Enum.reduce(nil, fn combo, min_presses ->
      state =
        button_masks
        |> Enum.with_index()
        |> Enum.reduce(0, fn {mask, btn_idx}, state ->
          if (combo &&& (1 <<< btn_idx)) != 0 do
            Bitwise.bxor(state, mask)
          else
            state
          end
        end)

      if state == target do
        presses = count_bits(combo)
        if min_presses == nil or presses < min_presses do
          presses
        else
          min_presses
        end
      else
        min_presses
      end
    end)
  end

  defp count_bits(n), do: count_bits(n, 0)
  defp count_bits(0, acc), do: acc
  defp count_bits(n, acc), do: count_bits(n >>> 1, acc + (n &&& 1))

  def run do
    input = File.read!("puzzle_inputpart01.txt")
    result = solve(input)
    IO.puts("Result: #{result}")
  end
end

test_input = """
[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
"""

IO.puts("Testing with examples:")
test_result = Day10Part01.solve(test_input)
IO.puts("Test result: #{test_result} (expected: 7)")

IO.puts("\nSolving puzzle input:")
Day10Part01.run()
