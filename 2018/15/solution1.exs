defmodule Unit do
  def new(char), do: {char, 200}

  def type({type, _}), do: type

  def will_die?({_type, hp}), do: hp <= 3

  def take_a_hit({type, hp}), do: {type, hp - 3}

  def hp({_, hp}), do: hp
end

defmodule Battle do
  def parse(text) do
    text = text |> String.split("\n", trim: true) |> Enum.map(&String.graphemes/1)

    for {line, y} <- Enum.with_index(text), {char, x} <- Enum.with_index(line) do
      {{x, y}, char}
    end
    |> Enum.reduce({%{}, %{}, false}, fn {pos, char}, {map, units, early_stop} ->
      case char do
        unit when unit in ~w(G E) ->
          {Map.put(map, pos, "."), Map.put(units, pos, Unit.new(char)), early_stop}

        other ->
          {Map.put(map, pos, other), units, early_stop}
      end
    end)
  end

  def step({map, initial_units, _}) do
    {new_units, early_stop} =
      initial_units
      |> Enum.sort_by(fn {{x, y}, _} -> {y, x} end)
      |> Enum.reduce({initial_units, false}, fn {pos, _}, {units, early_stop} ->
        early_stop = early_stop or not ongoing?({nil, units, nil})

        case units[pos] do
          nil ->
            {units, early_stop}

          unit ->
            new_pos = path(pos, unit, {map, units})
            new_units = units |> Map.delete(pos) |> Map.put(new_pos, unit)

            new_pos
            |> adjacent()
            |> Enum.map(&{&1, new_units[&1]})
            |> Enum.filter(&elem(&1, 1))
            |> Enum.filter(&(Unit.type(elem(&1, 1)) != Unit.type(unit)))
            |> Enum.map(&elem(&1, 0))
            |> Enum.sort_by(fn {x, y} -> {Unit.hp(new_units[{x, y}]), y, x} end)
            |> case do
              [] ->
                {new_units, early_stop}

              [attackable | _rest] ->
                if Unit.will_die?(new_units[attackable]) do
                  {Map.delete(new_units, attackable), early_stop}
                else
                  {Map.update!(new_units, attackable, &Unit.take_a_hit/1), early_stop}
                end
            end
        end
      end)

    {map, new_units, early_stop}
  end

  defp path(pos, unit, {map, units}) do
    dist_map =
      units
      |> Enum.filter(fn {_, u} -> Unit.type(u) != Unit.type(unit) end)
      |> Enum.map(&elem(&1, 0))
      |> Enum.flat_map(&adjacent/1)
      |> Enum.map(&{&1, 1})
      |> :queue.from_list()
      |> do_path({map, Map.delete(units, pos)})

    if dist_map[pos] == 1 do
      pos
    else
      adjacent(pos)
      |> Enum.filter(&dist_map[&1])
      |> Enum.sort_by(fn {x, y} -> {dist_map[{x, y}], y, x} end)
      |> case do
        [] -> pos
        [first | _rest] -> first
      end
    end
  end

  defp adjacent({x, y}), do: [{x + 1, y}, {x, y + 1}, {x - 1, y}, {x, y - 1}]

  defp do_path(queue, {map, units}, path_map \\ %{}) do
    case :queue.out(queue) do
      {:empty, _queue} ->
        path_map

      {{:value, {pos, distance}}, queue} ->
        if !path_map[pos] and !units[pos] and map[pos] == "." do
          queue =
            Enum.reduce(adjacent(pos), queue, fn pos, queue ->
              :queue.in({pos, distance + 1}, queue)
            end)

          do_path(queue, {map, units}, Map.put(path_map, pos, distance))
        else
          do_path(queue, {map, units}, path_map)
        end
    end
  end

  def inspect({map, units, _}) do
    max_x = map |> Map.keys() |> Enum.map(&elem(&1, 0)) |> Enum.max()
    max_y = map |> Map.keys() |> Enum.map(&elem(&1, 1)) |> Enum.max()

    for y <- 0..max_y do
      for x <- 0..max_x do
        case units[{x, y}] do
          nil -> IO.write(map[{x, y}])
          unit -> IO.write(Unit.type(unit))
        end
      end

      IO.puts("")
    end

    IO.puts("")
  end

  def ongoing?({_, units, _}) do
    units |> Enum.group_by(&Unit.type(elem(&1, 1))) |> Enum.count() > 1
  end

  def score({_, units, _}) do
    units |> Map.values() |> Enum.map(&Unit.hp/1) |> Enum.sum()
  end

  def early_stop?({_, _, early_stop}), do: early_stop
end

File.read!("input.txt")
|> Battle.parse()
|> Stream.iterate(&Battle.step/1)
|> Stream.with_index()
|> Stream.drop_while(&Battle.ongoing?(elem(&1, 0)))
|> Stream.map(fn {battle, turns} ->
  if Battle.early_stop?(battle) do
    Battle.score(battle) * (turns - 1)
  else
    Battle.score(battle) * turns
  end
end)
|> Enum.take(1)
|> IO.inspect()
