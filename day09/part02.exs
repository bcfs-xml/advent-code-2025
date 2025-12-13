defmodule Day09Part02 do
  def solve(input) do
    coords = parse_coordinates(input)
    edges = build_edges(coords)

    coords
    |> pairs()
    |> Enum.filter(fn {p1, p2} -> valid_rectangle?(p1, p2, coords, edges) end)
    |> Enum.map(fn {{x1, y1}, {x2, y2}} ->
      (abs(x2 - x1) + 1) * (abs(y2 - y1) + 1)
    end)
    |> Enum.max(fn -> 0 end)
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

  defp build_edges(coords) do
    coords
    |> Enum.chunk_every(2, 1, [hd(coords)])
    |> Enum.map(fn [{x1, y1}, {x2, y2}] ->
      {min(x1, x2), min(y1, y2), max(x1, x2), max(y1, y2)}
    end)
  end

  defp valid_rectangle?({x1, y1}, {x2, y2}, coords, edges) do
    min_x = min(x1, x2)
    max_x = max(x1, x2)
    min_y = min(y1, y2)
    max_y = max(y1, y2)

    corner1 = {min_x, max_y}
    corner2 = {max_x, min_y}

    point_in_polygon?(corner1, coords, edges) and
      point_in_polygon?(corner2, coords, edges) and
      not edge_crosses_interior?(edges, min_x, max_x, min_y, max_y)
  end

  defp point_in_polygon?({px, py}, coords, edges) do
    coord_set = MapSet.new(coords)

    if MapSet.member?(coord_set, {px, py}) do
      true
    else
      on_edge = Enum.any?(edges, fn {ex1, ey1, ex2, ey2} ->
        cond do
          ey1 == ey2 and py == ey1 and px >= ex1 and px <= ex2 -> true
          ex1 == ex2 and px == ex1 and py >= ey1 and py <= ey2 -> true
          true -> false
        end
      end)

      if on_edge do
        true
      else
        ray_casting(px, py, edges)
      end
    end
  end

  defp ray_casting(px, py, edges) do
    crossings =
      edges
      |> Enum.filter(fn {ex1, ey1, ex2, ey2} ->
        ex1 == ex2 and py >= ey1 and py < ey2 and px < ex1
      end)
      |> length()

    rem(crossings, 2) == 1
  end

  defp edge_crosses_interior?(edges, min_x, max_x, min_y, max_y) do
    Enum.any?(edges, fn {ex1, ey1, ex2, ey2} ->
      cond do
        ey1 == ey2 ->
          ey1 > min_y and ey1 < max_y and ex1 < max_x and ex2 > min_x

        ex1 == ex2 ->
          ex1 > min_x and ex1 < max_x and ey1 < max_y and ey2 > min_y

        true ->
          false
      end
    end)
  end

  defp pairs(list) do
    for {a, i} <- Enum.with_index(list),
        {b, j} <- Enum.with_index(list),
        i < j,
        do: {a, b}
  end
end

input = File.read!("puzzle_inputpart01.txt")
result = Day09Part02.solve(input)
IO.puts("Largest valid rectangle area: #{result}")
