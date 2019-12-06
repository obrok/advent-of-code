defmodule Cave do
  @magic_number 20183
  @magic_number_x 16807
  @magic_number_y 48271

  def erosion_levels(depth, target, max_x, max_y) do
    map =
      for x <- 0..max_x, y <- 0..max_y do
        {x, y}
      end
      |> Enum.reduce(%{}, fn pos, map ->
        Map.put(map, pos, erosion_level(pos, map, target, depth))
      end)

    %{map: map, depth: depth, target: target}
  end

  def bfs(cave, visited \\ %{}, queue \\ nil) do
    queue = queue || :queue.in({{{0, 0}, :torch}, 0}, :queue.new())

    case :queue.out(queue) do
      {{:value, {{pos, tool}, dist}}, queue} ->
        {visited, queue} =
          if !visited[{pos, tool}] || visited[{pos, tool}] > dist do
            visited = Map.put(visited, {pos, tool}, dist)
            queue = Enum.reduce(possible_moves(cave, {pos, tool}, dist), queue, &:queue.in/2)
            {visited, queue}
          else
            {visited, queue}
          end

        bfs(cave, visited, queue)

      _ ->
        visited
    end
  end

  def time_to_target(distances, target) do
    distances[{target, :torch}]
  end

  defp possible_moves(cave, {{x, y}, tool}, dist) do
    [
      {{{x, y}, :torch}, dist + 7},
      {{{x, y}, :climbing}, dist + 7},
      {{{x, y}, :neither}, dist + 7},
      {{{x + 1, y}, tool}, dist + 1},
      {{{x, y + 1}, tool}, dist + 1},
      {{{x, y - 1}, tool}, dist + 1},
      {{{x - 1, y}, tool}, dist + 1}
    ]
    |> Enum.filter(&valid_move?(cave, &1))
  end

  defp valid_move?(cave, {{pos, tool}, _dist}) do
    if cave.map[pos] do
      case rem(cave.map[pos], 3) do
        0 -> tool in [:climbing, :torch]
        1 -> tool in [:climbing, :neither]
        2 -> tool in [:torch, :neither]
      end
    else
      false
    end
  end

  defp erosion_level({0, 0}, _map, _target, depth), do: rem(depth, @magic_number)
  defp erosion_level(target, _map, target, depth), do: rem(depth, @magic_number)

  defp erosion_level({x, 0}, _map, _target, depth),
    do: rem(x * @magic_number_x + depth, @magic_number)

  defp erosion_level({0, y}, _map, _target, depth),
    do: rem(y * @magic_number_y + depth, @magic_number)

  defp erosion_level({x, y}, map, _target, depth),
    do: rem(map[{x - 1, y}] * map[{x, y - 1}] + depth, @magic_number)
end

depth = 3066
target = {13, 726}

# target = {10, 10}
# depth = 510

Cave.erosion_levels(depth, target, elem(target, 0) + 100, elem(target, 1) + 100)
|> Cave.bfs()
|> Cave.time_to_target(target)
|> IO.inspect()
