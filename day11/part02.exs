defmodule Day11Part02 do
  import Bitwise

  def solve(file_path) do
    graph =
      file_path
      |> File.read!()
      |> parse_input()

    # Usando memoização com ETS para contar caminhos eficientemente
    # Estado: {nó_atual, mask} onde mask representa quais nós obrigatórios foram visitados
    # mask: 0 = nenhum, 1 = só dac, 2 = só fft, 3 = ambos
    :ets.new(:memo, [:named_table, :set, :public])

    result = count_paths(graph, "svr", "out", 0, ["dac", "fft"])

    :ets.delete(:memo)
    result
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

  defp count_paths(_graph, target, target, mask, required_nodes) do
    # Chegamos ao destino, verificar se passamos por todos os nós obrigatórios
    required_mask = (1 <<< length(required_nodes)) - 1
    if mask == required_mask, do: 1, else: 0
  end

  defp count_paths(graph, current, target, mask, required_nodes) do
    key = {current, mask}

    case :ets.lookup(:memo, key) do
      [{^key, cached_result}] ->
        cached_result

      [] ->
        # Atualizar o mask se estamos em um nó obrigatório
        new_mask = update_mask(current, mask, required_nodes)

        result =
          case Map.get(graph, current, []) do
            [] -> 0
            outputs ->
              Enum.reduce(outputs, 0, fn next_device, acc ->
                acc + count_paths(graph, next_device, target, new_mask, required_nodes)
              end)
          end

        :ets.insert(:memo, {key, result})
        result
    end
  end

  defp update_mask(node, mask, required_nodes) do
    case Enum.find_index(required_nodes, &(&1 == node)) do
      nil -> mask
      index -> Bitwise.bor(mask, 1 <<< index)
    end
  end
end

result = Day11Part02.solve("puzzle_inputpart02.txt")
IO.puts("Number of paths is: #{result}")
