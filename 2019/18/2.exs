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
  def parse(input) do
    for {line, y} <- input |> String.split("\n") |> Enum.with_index(),
        {char, x} <- line |> String.graphemes() |> Enum.with_index(),
        into: %{} do
      {{x, y}, char}
    end
  end

  def to_graph(map) do
    map
    |> Map.values()
    |> Enum.reject(&(&1 in [".", "#"]))
    |> Enum.reject(&door?(&1))
    |> Map.new(&{&1, bfs(map, &1)})
  end

  def replace_start(graph) do
    {x, y} = graph |> Map.keys() |> Enum.find(&(graph[&1] == "@"))

    graph
    |> Map.put({x, y}, "#")
    |> Map.put({x - 1, y}, "#")
    |> Map.put({x + 1, y}, "#")
    |> Map.put({x, y + 1}, "#")
    |> Map.put({x, y - 1}, "#")
    |> Map.put({x + 1, y + 1}, "@1")
    |> Map.put({x + 1, y - 1}, "@2")
    |> Map.put({x - 1, y + 1}, "@3")
    |> Map.put({x - 1, y - 1}, "@4")
  end

  def bfs(graph, from) do
    start = graph |> Map.keys() |> Enum.find(&(graph[&1] == from))
    queue = :queue.from_list([{start, 0, MapSet.new()}])
    do_bfs(graph, queue, MapSet.new(), %{})
  end

  def do_bfs(_graph, {[], []}, _visited, distances), do: distances

  def do_bfs(graph, queue, visited, distances) do
    {{:value, {current, distance, doors}}, queue} = :queue.out(queue)

    if MapSet.member?(visited, {current, doors}) do
      do_bfs(graph, queue, visited, distances)
    else
      doors = if door?(graph[current]), do: MapSet.put(doors, String.downcase(graph[current])), else: doors

      queue =
        neighbours(current)
        |> Enum.filter(&(graph[&1] != "#"))
        |> Enum.reduce(queue, fn neighbor, queue ->
          :queue.in({neighbor, distance + 1, doors}, queue)
        end)

      distances =
        if graph[current] != "." && !door?(graph[current]) do
          Map.update(distances, graph[current], [{doors, distance}], fn known_paths ->
            if Enum.any?(known_paths, &MapSet.subset?(elem(&1, 0), doors)) do
              known_paths
            else
              [{doors, distance} | known_paths]
            end
          end)
        else
          distances
        end

      do_bfs(graph, queue, MapSet.put(visited, {current, doors}), distances)
    end
  end

  def collect(graph) do
    start = %{1 => "@1", 2 => "@2", 3 => "@3", 4 => "@4"}

    doors_to_open =
      graph |> Map.keys() |> Enum.filter(&(!String.contains?(&1, "@"))) |> Enum.map(&String.upcase/1) |> Enum.count()

    do_collect(PriorityQueue.singleton(0, {start, MapSet.new()}), graph, MapSet.new(), doors_to_open)
  end

  def do_collect(queue, graph, visited, doors_to_open, i \\ 0) do
    {distance, {positions, open_doors}, queue} = PriorityQueue.pop_min(queue)

    cond do
      Enum.count(open_doors) == doors_to_open ->
        distance

      MapSet.member?(visited, open_doors) ->
        do_collect(queue, graph, visited, doors_to_open, i + 1)

      true ->
        for {worker, position} <- positions,
            {to, known_paths} <- graph[position],
            {required_doors, distance} <- known_paths,
            MapSet.subset?(required_doors, open_doors),
            distance > 0,
            !String.contains?(to, "@") do
          {worker, to, distance}
        end
        |> Enum.reduce(queue, fn {worker, to, dist}, queue ->
          PriorityQueue.push(
            queue,
            distance + dist,
            {Map.put(positions, worker, to), MapSet.put(open_doors, to)}
          )
        end)
        |> do_collect(graph, MapSet.put(visited, open_doors), doors_to_open, i + 1)
    end
  end

  def neighbours({x, y}), do: [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]

  def door?(terrain), do: terrain != "." && !String.contains?(terrain, "@") && String.upcase(terrain) == terrain

  def passable?(terrain, keys) do
    cond do
      terrain == "#" -> false
      terrain == "." -> true
      String.downcase(terrain) == terrain -> true
      true -> String.downcase(terrain) in keys
    end
  end
end

File.read!("input")
|> String.trim()
|> Graph.parse()
|> Graph.replace_start()
|> Graph.to_graph()
|> Graph.collect()
|> IO.inspect()
