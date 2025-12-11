defmodule Day06 do
  def solve(filename) do
    lines =
      filename
      |> File.read!()
      |> String.replace("\r", "")
      |> String.split("\n", trim: true)

    {number_lines, [operator_line]} = Enum.split(lines, -1)

    char_grid = Enum.map(number_lines, &String.graphemes/1)
    operator_chars = String.graphemes(operator_line)

    max_width = Enum.max([length(operator_chars) | Enum.map(char_grid, &length/1)])

    char_grid = Enum.map(char_grid, fn row ->
      row ++ List.duplicate(" ", max_width - length(row))
    end)

    operator_chars = operator_chars ++ List.duplicate(" ", max_width - length(operator_chars))

    columns =
      0..(max_width - 1)
      |> Enum.map(fn col_idx ->
        numbers_in_col = Enum.map(char_grid, fn row -> Enum.at(row, col_idx, " ") end)
        operator = Enum.at(operator_chars, col_idx, " ")
        {numbers_in_col, operator}
      end)

    problems = group_into_problems(columns, [], [])

    results =
      problems
      |> Enum.map(&solve_problem/1)

    Enum.sum(results)
  end

  defp group_into_problems([], current_problem, problems) do
    if current_problem == [] do
      problems
    else
      problems ++ [Enum.reverse(current_problem)]
    end
  end

  defp group_into_problems([{numbers_col, operator} | rest], current_problem, problems) do
    all_spaces = Enum.all?(numbers_col, &(&1 == " ")) and operator == " "

    if all_spaces do
      if current_problem == [] do
        group_into_problems(rest, [], problems)
      else
        group_into_problems(rest, [], problems ++ [Enum.reverse(current_problem)])
      end
    else
      group_into_problems(rest, [{numbers_col, operator} | current_problem], problems)
    end
  end

  defp solve_problem(columns) do
    num_rows = length(elem(hd(columns), 0))

    numbers =
      0..(num_rows - 1)
      |> Enum.map(fn row_idx ->
        columns
        |> Enum.map(fn {nums, _op} -> Enum.at(nums, row_idx) end)
        |> Enum.join()
        |> String.trim()
        |> String.to_integer()
      end)

    operator =
      columns
      |> Enum.map(fn {_nums, op} -> op end)
      |> Enum.find(fn op -> op == "+" or op == "*" end)

    case operator do
      "+" -> Enum.sum(numbers)
      "*" -> Enum.product(numbers)
    end
  end
end

result = Day06.solve("puzzle_inputpart01.txt")
IO.puts("Grand Total: #{result}")
