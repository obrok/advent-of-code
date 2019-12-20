defmodule PriorityQueue do
  def empty(), do: :empty

  def singleton(key, value), do: {key, value, :empty, :empty, 1}

  def pop_min(:empty), do: :empty
  def pop_min({k, v, l, r, _}), do: {k, v, merge(l, r)}

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

defmodule Graph do
  def parse_map(input) do
    for {line, y} <- input |> String.split("\n") |> Enum.with_index(),
        {char, x} <- line |> String.graphemes() |> Enum.with_index(),
        into: %{} do
      {{x, y}, char}
    end
  end

  def mark_portals(map) do
    x_range = map |> Map.keys() |> Enum.map(&elem(&1, 0)) |> Enum.min_max()
    y_range = map |> Map.keys() |> Enum.map(&elem(&1, 1)) |> Enum.min_max()

    map
    |> Map.keys()
    |> Enum.reduce({map, %{}}, fn {x, y}, {map, portals} ->
      cond do
        passable?(map, {x, y}) && letter?(map, {x + 1, y}) && letter?(map, {x + 2, y}) ->
          {:portal, label(map, {x + 1, y}, {x + 2, y}, x_range, y_range)}

        passable?(map, {x, y}) && letter?(map, {x - 1, y}) && letter?(map, {x - 2, y}) ->
          {:portal, label(map, {x - 2, y}, {x - 1, y}, x_range, y_range)}

        passable?(map, {x, y}) && letter?(map, {x, y + 1}) && letter?(map, {x, y + 2}) ->
          {:portal, label(map, {x, y + 1}, {x, y + 2}, x_range, y_range)}

        passable?(map, {x, y}) && letter?(map, {x, y - 1}) && letter?(map, {x, y - 2}) ->
          {:portal, label(map, {x, y - 2}, {x, y - 1}, x_range, y_range)}

        true ->
          nil
      end
      |> case do
        {:portal, label} ->
          {
            Map.put(map, {x, y}, {:portal, label}),
            Map.put(portals, label, {x, y})
          }

        _ ->
          {map, portals}
      end
    end)
  end

  def to_weighted({map, portals}) do
    for {label, position} <- portals, into: %{} do
      {
        label,
        bfs(map, position) |> Enum.reject(&(elem(&1, 1) == 0)) |> Enum.into(%{})
      }
    end
  end

  def bfs(map, start) do
    queue = :queue.from_list([{start, 0}])
    do_bfs(map, queue, MapSet.new(), %{})
  end

  def do_bfs(_, {[], []}, _, distances), do: distances

  def do_bfs(map, queue, visited, distances) do
    {{:value, {current, distance}}, queue} = :queue.out(queue)

    if MapSet.member?(visited, current) do
      do_bfs(map, queue, visited, distances)
    else
      visited = MapSet.put(visited, current)

      queue =
        neighbors(map, current)
        |> Enum.reduce(queue, fn neighbor, queue -> :queue.in({neighbor, distance + 1}, queue) end)

      distances =
        case map[current] do
          {:portal, label} -> Map.put(distances, label, distance)
          _ -> distances
        end

      do_bfs(map, queue, visited, distances)
    end
  end

  def neighbors(map, {x, y}) do
    [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}] |> Enum.filter(&passable?(map, &1))
  end

  def passable?(map, pos) do
    case map[pos] do
      {:portal, _} -> true
      "." -> true
      _ -> false
    end
  end

  def letter?(map, pos) do
    case map[pos] do
      nil -> false
      "." -> false
      "#" -> false
      " " -> false
      {:portal, _} -> false
      _ -> true
    end
  end

  def label(map, {x1, y1}, {x2, y2}, {min_x, max_x}, {min_y, max_y}) do
    bounds = [min_x, max_x, min_y, max_y]
    name = "#{map[{x1, y1}]}#{map[{x2, y2}]}"

    if x1 in bounds || x2 in bounds || y1 in bounds || y2 in bounds do
      {:outer, name}
    else
      {:inner, name}
    end
  end

  def dijkstra(graph, start, finish) do
    start = {start, 0}
    finish = {finish, 0}
    queue = PriorityQueue.singleton(0, start)
    do_dijkstra(graph, queue, MapSet.new(), finish)
  end

  def do_dijkstra(graph, queue, visited, finish) do
    {distance, current, queue} = PriorityQueue.pop_min(queue)

    cond do
      current == finish ->
        distance

      MapSet.member?(visited, current) ->
        do_dijkstra(graph, queue, visited, finish)

      true ->
        visited = MapSet.put(visited, current)

        queue =
          moves(graph, current)
          |> Enum.reduce(queue, fn {move, dist}, queue -> PriorityQueue.push(queue, distance + dist, move) end)

        do_dijkstra(graph, queue, visited, finish)
    end
  end

  def moves(graph, {label, level}) do
    flip({label, level}) ++ Enum.map(graph[label], fn {label, distance} -> {{label, level}, distance} end)
  end

  def flip({{_, "AA"}, _}), do: []
  def flip({{_, "ZZ"}, _}), do: []
  def flip({{:outer, _}, 0}), do: []
  def flip({{:outer, label}, level}), do: [{{{:inner, label}, level - 1}, 1}]
  def flip({{:inner, label}, level}), do: [{{{:outer, label}, level + 1}, 1}]
end

File.read!("input")
|> String.trim("\n")
|> Graph.parse_map()
|> Graph.mark_portals()
|> Graph.to_weighted()
|> Graph.dijkstra({:outer, "AA"}, {:outer, "ZZ"})
|> IO.inspect()
