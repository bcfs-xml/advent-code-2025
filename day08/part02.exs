defmodule Day08Part2 do
  def solve(input_file) do
    boxes =
      input_file
      |> File.read!()
      |> String.trim()
      |> String.replace("\r", "")
      |> String.split("\n")
      |> Enum.with_index()
      |> Enum.map(fn {line, idx} ->
        [x, y, z] = line |> String.split(",") |> Enum.map(&String.to_integer/1)
        {idx, {x, y, z}}
      end)
      |> Map.new()

    n = map_size(boxes)

    distances =
      for i <- 0..(n - 2),
          j <- (i + 1)..(n - 1) do
        {x1, y1, z1} = boxes[i]
        {x2, y2, z2} = boxes[j]
        dist_sq = (x2 - x1) ** 2 + (y2 - y1) ** 2 + (z2 - z1) ** 2
        {dist_sq, i, j}
      end

    sorted_distances = Enum.sort_by(distances, fn {dist, _, _} -> dist end)

    uf = UnionFind.new(n)

    # Connect pairs until all boxes are in one circuit
    {_uf, last_i, last_j} = find_last_connection(sorted_distances, uf, n)

    {x1, _, _} = boxes[last_i]
    {x2, _, _} = boxes[last_j]
    result = x1 * x2

    IO.puts("Last connection: box #{last_i} (X=#{x1}) and box #{last_j} (X=#{x2})")
    IO.puts("Result: #{result}")
    result
  end

  defp find_last_connection([], _uf, _n), do: raise("No solution found")

  defp find_last_connection([{_dist, i, j} | rest], uf, n) do
    {uf_after_find_i, root_i} = UnionFind.find(uf, i)
    {uf_after_find_j, root_j} = UnionFind.find(uf_after_find_i, j)

    if root_i == root_j do
      # Same circuit, skip this connection
      find_last_connection(rest, uf_after_find_j, n)
    else
      # Different circuits, make the connection
      new_uf = UnionFind.union(uf_after_find_j, i, j)

      # Check if all boxes are now in one circuit
      if all_connected?(new_uf, n) do
        {new_uf, i, j}
      else
        find_last_connection(rest, new_uf, n)
      end
    end
  end

  defp all_connected?(uf, n) do
    roots =
      0..(n - 1)
      |> Enum.map(fn i ->
        {_uf, root} = UnionFind.find(uf, i)
        root
      end)
      |> Enum.uniq()

    length(roots) == 1
  end
end

defmodule UnionFind do
  defstruct [:parent, :rank]

  def new(n) do
    parent = 0..(n - 1) |> Enum.map(&{&1, &1}) |> Map.new()
    rank = 0..(n - 1) |> Enum.map(&{&1, 0}) |> Map.new()
    %UnionFind{parent: parent, rank: rank}
  end

  def find(%UnionFind{parent: parent} = uf, x) do
    if parent[x] == x do
      {uf, x}
    else
      {uf, root} = find(uf, parent[x])
      new_parent = Map.put(uf.parent, x, root)
      {%{uf | parent: new_parent}, root}
    end
  end

  def union(uf, x, y) do
    {uf, root_x} = find(uf, x)
    {uf, root_y} = find(uf, y)

    if root_x == root_y do
      uf
    else
      rank_x = uf.rank[root_x]
      rank_y = uf.rank[root_y]

      cond do
        rank_x < rank_y ->
          %{uf | parent: Map.put(uf.parent, root_x, root_y)}

        rank_x > rank_y ->
          %{uf | parent: Map.put(uf.parent, root_y, root_x)}

        true ->
          new_parent = Map.put(uf.parent, root_y, root_x)
          new_rank = Map.put(uf.rank, root_x, rank_x + 1)
          %{uf | parent: new_parent, rank: new_rank}
      end
    end
  end
end

Day08Part2.solve("puzzle_inputpart01.txt")
