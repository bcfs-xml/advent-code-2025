defmodule Day12Part01 do
  def solve(input) do
    {shapes, regions} = parse(input)

    shape_info =
      shapes
      |> Enum.map(fn {idx, coords} ->
        size = length(coords)
        {whites, blacks} = Enum.reduce(coords, {0, 0}, fn {r, c}, {w, b} ->
          if rem(r + c, 2) == 0, do: {w + 1, b}, else: {w, b + 1}
        end)
        {idx, {size, whites, blacks}}
      end)
      |> Map.new()

    regions
    |> Enum.map(fn {width, height, quantities} ->
      can_fit?(width, height, quantities, shape_info)
    end)
    |> Enum.count(& &1)
  end

  defp parse(input) do
    lines =
      input
      |> String.replace("\r", "")
      |> String.split("\n")

    {shape_lines, region_lines} =
      Enum.split_while(lines, fn line ->
        not String.match?(line, ~r/^\d+x\d+:/)
      end)

    shapes = parse_shapes(shape_lines)
    regions = parse_regions(region_lines)

    {shapes, regions}
  end

  defp parse_shapes(lines) do
    lines
    |> Enum.chunk_by(&(&1 == ""))
    |> Enum.reject(fn chunk -> chunk == [""] end)
    |> Enum.map(&parse_shape/1)
    |> Map.new()
  end

  defp parse_shape(lines) do
    [header | shape_lines] = lines
    idx = header |> String.trim_trailing(":") |> String.to_integer()

    coords =
      shape_lines
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, row} ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.filter(fn {char, _col} -> char == "#" end)
        |> Enum.map(fn {_char, col} -> {row, col} end)
      end)

    {idx, coords}
  end

  defp parse_regions(lines) do
    lines
    |> Enum.filter(&(String.trim(&1) != ""))
    |> Enum.map(&parse_region/1)
  end

  defp parse_region(line) do
    [dims | quantities] = String.split(line, ~r/[:\s]+/, trim: true)
    [width, height] = dims |> String.split("x") |> Enum.map(&String.to_integer/1)
    qtys = Enum.map(quantities, &String.to_integer/1)
    {width, height, qtys}
  end

  defp can_fit?(width, height, quantities, shape_info) do
    region_area = width * height
    region_whites = div(width * height + 1, 2)
    region_blacks = div(width * height, 2)

    total_cells =
      quantities
      |> Enum.with_index()
      |> Enum.reduce(0, fn {qty, idx}, acc ->
        {size, _w, _b} = Map.get(shape_info, idx, {7, 4, 3})
        acc + qty * size
      end)

    if total_cells > region_area do
      false
    else

      min_whites =
        quantities
        |> Enum.with_index()
        |> Enum.reduce(0, fn {qty, idx}, acc ->
          {_size, w, b} = Map.get(shape_info, idx, {7, 4, 3})
          acc + qty * min(w, b)
        end)

      max_whites =
        quantities
        |> Enum.with_index()
        |> Enum.reduce(0, fn {qty, idx}, acc ->
          {_size, w, b} = Map.get(shape_info, idx, {7, 4, 3})
          acc + qty * max(w, b)
        end)


      lower_bound = max(min_whites, total_cells - region_blacks)
      upper_bound = min(max_whites, region_whites)

      lower_bound <= upper_bound
    end
  end
end

input = File.read!("puzzle_inputpart01.txt")
result = Day12Part01.solve(input)
IO.puts("Answer: #{result}")
