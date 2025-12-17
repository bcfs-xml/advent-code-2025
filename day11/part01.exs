defmodule Day11Part01 do
  def solve(file_path) do
    file_path
    |> File.read!()
    |> parse_input()
    |> count_paths("you", "out")
  end

  defp parse_input(input) do
    input
    |> String.replace("\r", "")
    |> String.trim()
    |> String.split("\n")
    |> Enum.reduce(%{}, fn line, graph ->
      [device, outputs] = String.split(line, ": ")
      outputs_list = String.split(outputs, " ")
      Map.put(graph, device, outputs_list)
    end)
  end

  defp count_paths(graph, start, target) do
    find_all_paths(graph, start, target, MapSet.new())
  end

  defp find_all_paths(_graph, target, target, _visited) do
    1
  end

  defp find_all_paths(graph, current, target, visited) do
    cond do
      MapSet.member?(visited, current) ->
        0
      true ->
        case Map.get(graph, current, []) do
          [] -> 0
          outputs ->
            new_visited = MapSet.put(visited, current)
            Enum.reduce(outputs, 0, fn next_device, acc ->
              acc + find_all_paths(graph, next_device, target, new_visited)
            end)
        end
    end
  end
end

result = Day11Part01.solve("puzzle_inputpart01.txt")
IO.puts("Number of paths is: #{result}")
