defmodule PriorityQueue do
  def empty(), do: :empty

  def singleton(key, value), do: {key, value, :empty, :empty, 1}

  def pop_min(:empty), do: :empty
  def pop_min({_, v, l, r, _}), do: {v, merge(l, r)}

  def push(queue, key, value), do: merge(queue, singleton(key, value))

  defp rank(:empty), do: 0
  defp rank({_, _, _, _, rank}), do: rank

  defp merge(:empty, tree), do: tree
  defp merge(tree, :empty), do: tree

  defp merge(tree1 = {k1, _, _, _, _}, tree2 = {k2, _, _, _, _}) when k1 > k2,
    do: merge(tree2, tree1)

  defp merge({k, v, l, r, _}, tree2) do
    merged = merge(r, tree2)

    if rank(l) >= rank(merged) do
      {k, v, l, merged, rank(l) + 1}
    else
      {k, v, merged, l, rank(merged) + 1}
    end
  end
end

defmodule Cave do
  @magic_number 20183
  @magic_number_x 16807
  @magic_number_y 48271

  def build(depth, target) do
    %{map: %{}, target: target, depth: depth}
  end

  def a_star(cave, visited \\ %{}, queue \\ nil) do
    queue = queue || PriorityQueue.singleton(0, {{{0, 0}, :torch}, 0})

    case PriorityQueue.pop_min(queue) do
      {{{pos = {x, y}, tool}, dist}, queue} ->
        to_go =
          abs(elem(cave.target, 0) - x) + abs(elem(cave.target, 1) - y) +
            if(tool == :torch, do: 0, else: 7)

        {visited, queue, cave} =
          cond do
            visited[{cave.target, :torch}] ->
              {visited, PriorityQueue.empty(), cave}

            !visited[{pos, tool}] || visited[{pos, tool}] > dist ->
              visited = Map.put(visited, {pos, tool}, dist)

              {possible_moves, cave} = possible_moves(cave, {pos, tool}, dist)

              queue =
                Enum.reduce(possible_moves, queue, fn move = {_, dist}, queue ->
                  PriorityQueue.push(queue, dist + to_go, move)
                end)

              {visited, queue, cave}

            true ->
              {visited, queue, cave}
          end

        a_star(cave, visited, queue)

      :empty ->
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
    |> Enum.reduce({[], cave}, fn move, {moves, cave} ->
      {valid?, cave} = valid_move?(cave, move)
      if valid?, do: {[move | moves], cave}, else: {moves, cave}
    end)
  end

  defp valid_move?(cave, {{{x, y}, _tool}, _dist}) when x < 0 or y < 0, do: {false, cave}

  defp valid_move?(cave, {{pos, tool}, _dist}) do
    {erosion_level, cave} = erosion_level(pos, cave)

    {case rem(erosion_level, 3) do
       0 -> tool in [:climbing, :torch]
       1 -> tool in [:climbing, :neither]
       2 -> tool in [:torch, :neither]
     end, cave}
  end

  defp erosion_level({0, 0}, cave), do: {rem(cave.depth, @magic_number), cave}

  defp erosion_level(target, cave = %{target: target}),
    do: {rem(cave.depth, @magic_number), cave}

  defp erosion_level({x, 0}, cave),
    do: {rem(x * @magic_number_x + cave.depth, @magic_number), cave}

  defp erosion_level({0, y}, cave),
    do: {rem(y * @magic_number_y + cave.depth, @magic_number), cave}

  defp erosion_level({x, y}, cave) do
    if cave.map[{x, y}] do
      {cave.map[{x, y}], cave}
    else
      {x_level, cave} = erosion_level({x - 1, y}, cave)
      {y_level, cave} = erosion_level({x, y - 1}, cave)

      level = rem(x_level * y_level + cave.depth, @magic_number)
      cave = put_in(cave, [:map, {x, y}], level)

      {level, cave}
    end
  end
end

depth = 3066
target = {13, 726}

# target = {10, 10}
# depth = 510

Cave.build(depth, target)
|> Cave.a_star()
|> Cave.time_to_target(target)
|> IO.inspect()
