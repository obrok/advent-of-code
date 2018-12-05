File.read!("input.txt")
|> String.split("\n", trim: true)
|> Enum.sort()
|> Enum.reduce({nil, nil, %{}}, fn event, {guard, fell_asleep, result} ->
  cond do
    event =~ ~r/Guard/ ->
      [_, guard] = Regex.run(~r/#(\d*)/, event)
      {String.to_integer(guard), nil, result}

    event =~ ~r/falls asleep/ ->
      [_, seconds] = Regex.run(~r/:(\d*)/, event)
      {guard, String.to_integer(seconds), result}

    true ->
      [_, seconds] = Regex.run(~r/:(\d*)/, event)
      seconds = String.to_integer(seconds)

      guard_record =
        Enum.reduce(fell_asleep..(seconds - 1), Map.get(result, guard, %{}), fn second, acc ->
          Map.update(acc, second, 1, &(&1 + 1))
        end)

      {guard, nil, Map.put(result, guard, guard_record)}
  end
end)
|> (fn {_, _, records} -> records end).()
|> Enum.max_by(fn {_id, sleep_map} -> sleep_map |> Map.values() |> Enum.max() end)
|> (fn {id, sleep_map} -> {id, Enum.max_by(sleep_map, fn {_k, v} -> v end)} end).()
|> (fn {id, {best_second, _}} -> id * best_second end).()
|> IO.inspect()
