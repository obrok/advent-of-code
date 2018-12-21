defmodule Facility do
  def parse_parens(input, output \\ [])
  def parse_parens(["^" | rest], output), do: parse_parens(rest, output)
  def parse_parens(["$" | _rest], output), do: Enum.reverse(output)
  def parse_parens([")" | rest], output), do: {[Enum.reverse(output)], rest}

  def parse_parens(["|" | rest], output) do
    option = Enum.reverse(output)
    {options, rest} = parse_parens(rest, [])
    {[option | options], rest}
  end

  def parse_parens(["(" | rest], output) do
    {options, rest} = parse_parens(rest, [])
    parse_parens(rest, [{:options, options} | output])
  end

  def parse_parens([other | rest], output), do: parse_parens(rest, [other | output])

  def parse(input, current_rooms \\ MapSet.new([{0, 0}]), map \\ %{{0, 0} => MapSet.new()})

  def parse([], rooms, map), do: {map, rooms}

  def parse(["E" | rest], rooms, map), do: move(rest, rooms, fn {x, y} -> {x + 1, y} end, map)
  def parse(["W" | rest], rooms, map), do: move(rest, rooms, fn {x, y} -> {x - 1, y} end, map)
  def parse(["N" | rest], rooms, map), do: move(rest, rooms, fn {x, y} -> {x, y - 1} end, map)
  def parse(["S" | rest], rooms, map), do: move(rest, rooms, fn {x, y} -> {x, y + 1} end, map)

  def parse([{:options, options} | rest], current_rooms, map) when is_list(options) do
    {map, rooms} =
      Enum.reduce(options, {map, MapSet.new()}, fn option, {map, rooms} ->
        {map, new_rooms} = parse(option, current_rooms, map)
        {map, MapSet.union(rooms, new_rooms)}
      end)

    parse(rest, rooms, map)
  end

  defp move(path, old_rooms, move, map) do
    {map, rooms} =
      Enum.reduce(old_rooms, {map, []}, fn old_room, {map, rooms} ->
        current_room = move.(old_room)

        map =
          map
          |> Map.put_new(current_room, MapSet.new())
          |> Map.update!(old_room, &MapSet.put(&1, current_room))
          |> Map.update!(current_room, &MapSet.put(&1, old_room))

        {map, [current_room | rooms]}
      end)

    parse(path, MapSet.new(rooms), map)
  end

  def far(facility) do
    dfs(facility)
    |> Map.values()
    |> Enum.count(&(&1 >= 1000))
  end

  def dfs(facility, visited \\ %{}, queue \\ nil) do
    queue = queue || :queue.in({{0, 0}, 0}, :queue.new())

    case :queue.out(queue) do
      {{:value, {pos, dist}}, queue} ->
        if visited[pos] do
          dfs(facility, visited, queue)
        else
          visited = Map.put(visited, pos, dist)

          queue =
            Enum.reduce(facility[pos], queue, fn pos, queue ->
              :queue.in({pos, dist + 1}, queue)
            end)

          dfs(facility, visited, queue)
        end

      {:empty, _} ->
        visited
    end
  end
end

File.read!("input.txt")
|> String.graphemes()
|> Facility.parse_parens()
|> Facility.parse()
|> elem(0)
|> Facility.far()
|> IO.inspect()
