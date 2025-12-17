defmodule Day10Part02 do
  def solve(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_line/1)
    |> Enum.with_index(1)
    |> Enum.map(fn {{buttons, target}, idx} ->
      result = find_min_presses(buttons, target)
      result
    end)
    |> Enum.sum()
  end

  defp parse_line(line) do
    [_, target_str] = Regex.run(~r/\{([0-9,]+)\}/, line)
    target = target_str |> String.split(",") |> Enum.map(&String.to_integer/1)

    buttons =
      Regex.scan(~r/\(([0-9,]+)\)/, line)
      |> Enum.map(fn [_, indices_str] ->
        indices_str
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
        |> MapSet.new()
      end)

    {buttons, target}
  end

  defp find_min_presses(buttons, target) do
    num_counters = length(target)

    effects =
      buttons
      |> Enum.map(fn button ->
        for i <- 0..(num_counters - 1), do: if(MapSet.member?(button, i), do: 1, else: 0)
      end)
      |> Enum.uniq()

    num_buttons = length(effects)

    matrix =
      for i <- 0..(num_counters - 1) do
        for j <- 0..(num_buttons - 1) do
          Enum.at(effects, j) |> Enum.at(i)
        end
      end

    solve_system(matrix, target, num_counters, num_buttons)
  end

  defp solve_system(matrix, target, num_counters, num_buttons) do
    augmented =
      Enum.zip(matrix, target)
      |> Enum.map(fn {row, t} -> row ++ [t] end)

    {reduced, pivot_cols} = gaussian_elimination(augmented, num_counters, num_buttons)

    free_vars = Enum.to_list(0..(num_buttons - 1)) -- pivot_cols


    if free_vars == [] do

      solve_unique(reduced, num_buttons, pivot_cols)
    else

      search_with_free_vars(reduced, target, num_buttons, pivot_cols, free_vars)
    end
  end

  defp gaussian_elimination(matrix, num_rows, num_cols) do
    do_elimination(matrix, 0, 0, num_rows, num_cols, [])
  end

  defp do_elimination(matrix, row, col, num_rows, num_cols, pivot_cols) do
    cond do
      row >= num_rows or col >= num_cols ->
        {matrix, Enum.reverse(pivot_cols)}

      true ->

        pivot_row =
          row..(num_rows - 1)
          |> Enum.find(fn r ->
            val = matrix |> Enum.at(r) |> Enum.at(col)
            val != 0
          end)

        if pivot_row == nil do

          do_elimination(matrix, row, col + 1, num_rows, num_cols, pivot_cols)
        else

          matrix =
            if pivot_row != row do
              swap_rows(matrix, row, pivot_row)
            else
              matrix
            end

          matrix = eliminate_column(matrix, row, col, num_rows)

          do_elimination(matrix, row + 1, col + 1, num_rows, num_cols, [col | pivot_cols])
        end
    end
  end

  defp swap_rows(matrix, i, j) do
    row_i = Enum.at(matrix, i)
    row_j = Enum.at(matrix, j)

    matrix
    |> List.replace_at(i, row_j)
    |> List.replace_at(j, row_i)
  end

  defp eliminate_column(matrix, pivot_row, pivot_col, num_rows) do
    pivot_val = matrix |> Enum.at(pivot_row) |> Enum.at(pivot_col)

    0..(num_rows - 1)
    |> Enum.reduce(matrix, fn r, acc ->
      if r == pivot_row do
        acc
      else
        val = acc |> Enum.at(r) |> Enum.at(pivot_col)

        if val == 0 do
          acc
        else

          pivot_row_data = Enum.at(acc, pivot_row)
          row_r = Enum.at(acc, r)

          new_row =
            Enum.zip(row_r, pivot_row_data)
            |> Enum.map(fn {a, b} -> a * pivot_val - b * val end)

          gcd = new_row |> Enum.map(&abs/1) |> Enum.filter(&(&1 != 0)) |> gcd_list()
          gcd = if gcd == 0, do: 1, else: gcd

          new_row = Enum.map(new_row, &div(&1, gcd))

          List.replace_at(acc, r, new_row)
        end
      end
    end)
  end

  defp gcd_list([]), do: 0
  defp gcd_list([x]), do: abs(x)
  defp gcd_list([x | xs]), do: Integer.gcd(abs(x), gcd_list(xs))

  defp solve_unique(reduced, num_buttons, pivot_cols) do

    solution = List.duplicate(0, num_buttons)

    result =
      pivot_cols
      |> Enum.with_index()
      |> Enum.reverse()
      |> Enum.reduce_while({:ok, solution}, fn {col, row_idx}, {:ok, sol} ->
        row = Enum.at(reduced, row_idx)
        pivot_val = Enum.at(row, col)
        rhs = List.last(row)

        if pivot_val == 0 do
          if rhs == 0, do: {:cont, {:ok, sol}}, else: {:halt, {:no_solution}}
        else
          other_sum =
            0..(num_buttons - 1)
            |> Enum.filter(&(&1 != col))
            |> Enum.map(fn j ->
              coef = Enum.at(row, j) || 0
              val = Enum.at(sol, j) || 0
              coef * val
            end)
            |> Enum.sum()

          val = rhs - other_sum

          if rem(val, pivot_val) != 0 do
            {:halt, {:no_solution}}
          else
            x_val = div(val, pivot_val)

            if x_val < 0 do
              {:halt, {:no_solution}}
            else
              {:cont, {:ok, List.replace_at(sol, col, x_val)}}
            end
          end
        end
      end)

    case result do
      {:ok, sol} -> Enum.sum(sol)
      _ -> :infinity
    end
  end

  defp search_with_free_vars(reduced, _target, num_buttons, pivot_cols, free_vars) do

    max_free_val = 300

    free_ranges =
      free_vars
      |> Enum.map(fn _ -> 0..max_free_val end)

    search_free_vars(
      free_vars,
      free_ranges,
      [],
      reduced,
      num_buttons,
      pivot_cols,
      :infinity
    )
  end

  defp search_free_vars([], _ranges, free_vals, reduced, num_buttons, pivot_cols, best) do
    free_vals = Enum.reverse(free_vals)

    case solve_given_free(reduced, num_buttons, pivot_cols, free_vals) do
      {:ok, sol} ->
        cost = Enum.sum(sol)
        if cost < best, do: cost, else: best

      :no_solution ->
        best
    end
  end

  defp search_free_vars([_var | rest_vars], [range | rest_ranges], free_vals, reduced, num_buttons, pivot_cols, best) do

    current_free_sum = Enum.sum(free_vals)

    range
    |> Enum.reduce_while(best, fn val, current_best ->
      if current_free_sum + val >= current_best do

        {:halt, current_best}
      else
        new_best =
          search_free_vars(
            rest_vars,
            rest_ranges,
            [val | free_vals],
            reduced,
            num_buttons,
            pivot_cols,
            current_best
          )

        {:cont, new_best}
      end
    end)
  end

  defp solve_given_free(reduced, num_buttons, pivot_cols, free_vals) do

    free_var_indices = Enum.to_list(0..(num_buttons - 1)) -- pivot_cols


    solution =
      0..(num_buttons - 1)
      |> Enum.map(fn idx ->
        case Enum.find_index(free_var_indices, &(&1 == idx)) do
          nil -> 0
          i -> Enum.at(free_vals, i)
        end
      end)

    result =
      pivot_cols
      |> Enum.with_index()
      |> Enum.reverse()
      |> Enum.reduce_while({:ok, solution}, fn {col, row_idx}, {:ok, sol} ->
        row = Enum.at(reduced, row_idx)
        pivot_val = Enum.at(row, col)
        rhs = List.last(row)


        other_sum =
          0..(num_buttons - 1)
          |> Enum.filter(&(&1 != col))
          |> Enum.map(fn j -> Enum.at(row, j) * Enum.at(sol, j) end)
          |> Enum.sum()

        val = rhs - other_sum

        if pivot_val == 0 do
          if val == 0 do
            {:cont, {:ok, sol}}
          else
            {:halt, :no_solution}
          end
        else
          if rem(val, pivot_val) != 0 do
            {:halt, :no_solution}
          else
            x_val = div(val, pivot_val)

            if x_val < 0 do
              {:halt, :no_solution}
            else
              {:cont, {:ok, List.replace_at(sol, col, x_val)}}
            end
          end
        end
      end)

    case result do
      {:ok, sol} ->

        if Enum.all?(sol, &(&1 >= 0)), do: {:ok, sol}, else: :no_solution

      _ ->
        :no_solution
    end
  end

  def run do
    input = File.read!("puzzle_inputpart02.txt")
    result = solve(input)
    IO.puts("\nTotal Result: #{result}")
  end
end

test_input = """
[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
"""

test_result = Day10Part02.solve(test_input)

Day10Part02.run()
