defmodule Graph do
  def parse_map(input) do
    for {line, y} <- input |> String.split("\n") |> Enum.with_index(),
        {char, x} <- line |> String.graphemes() |> Enum.with_index(),
        into: %{} do
      {{x, y}, char}
    end
  end

  def mark_portals(map) do
    map
    |> Map.keys()
    |> Enum.reduce({map, %{}}, fn {x, y}, {map, portals} ->
      cond do
        passable?(map, {x, y}) && letter?(map, {x + 1, y}) && letter?(map, {x + 2, y}) ->
          {:portal, label(map, {x + 1, y}, {x + 2, y})}

        passable?(map, {x, y}) && letter?(map, {x - 1, y}) && letter?(map, {x - 2, y}) ->
          {:portal, label(map, {x - 2, y}, {x - 1, y})}

        passable?(map, {x, y}) && letter?(map, {x, y + 1}) && letter?(map, {x, y + 2}) ->
          {:portal, label(map, {x, y + 1}, {x, y + 2})}

        passable?(map, {x, y}) && letter?(map, {x, y - 1}) && letter?(map, {x, y - 2}) ->
          {:portal, label(map, {x, y - 2}, {x, y - 1})}

        true ->
          nil
      end
      |> case do
        {:portal, label} ->
          {
            Map.put(map, {x, y}, {:portal, label}),
            Map.update(portals, label, [{x, y}], fn known -> [{x, y} | known] end)
          }

        _ ->
          {map, portals}
      end
    end)
  end

  def bfs({map, portals}) do
    [start] = portals["AA"]
    [finish] = portals["ZZ"]
    queue = :queue.from_list([{start, 0}])
    do_bfs(map, portals, queue, MapSet.new(), finish)
  end

  def do_bfs(map, portals, queue, visited, finish) do
    {{:value, {current, distance}}, queue} = :queue.out(queue)

    cond do
      current == finish ->
        distance

      MapSet.member?(visited, current) ->
        do_bfs(map, portals, queue, visited, finish)

      true ->
        visited = MapSet.put(visited, current)

        queue =
          neighbors(map, portals, current)
          |> Enum.reduce(queue, fn neighbor, queue -> :queue.in({neighbor, distance + 1}, queue) end)

        do_bfs(map, portals, queue, visited, finish)
    end
  end

  def neighbors(map, portals, {x, y}) do
    case map[{x, y}] do
      {:portal, label} ->
        portal = portals[label] |> Enum.find(&(&1 != {x, y}))
        [portal, {x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}] |> Enum.filter(&passable?(map, &1))

      _ ->
        [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}] |> Enum.filter(&passable?(map, &1))
    end
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

  def label(map, pos1, pos2), do: "#{map[pos1]}#{map[pos2]}"
end

File.read!("input")
|> String.trim("\n")
|> Graph.parse_map()
|> Graph.mark_portals()
|> Graph.bfs()
|> IO.inspect()
