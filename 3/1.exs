defmodule Path do
  def parse_step(step) do
    captures = Regex.named_captures(~r/(?<dir>U|D|L|R)(?<dist>.*)/, step)
    {String.to_atom(captures["dir"]), String.to_integer(captures["dist"])}
  end

  def trace(steps) do
    {_, visited} = Enum.reduce(steps, {{0, 0}, MapSet.new}, fn step, {location, visited} ->
      trace_one(step, location, visited)
    end)
    visited
  end

  def trace_one(step, {x, y}, visited) do
    locations = case step do
      {:U, distance} -> y..(y + distance) |> Enum.map(&{x, &1})
      {:D, distance} -> y..(y - distance) |> Enum.map(&{x, &1})
      {:L, distance} -> x..(x - distance) |> Enum.map(&{&1, y})
      {:R, distance} -> x..(x + distance) |> Enum.map(&{&1, y})
    end

    {locations |> Enum.reverse() |> hd(), locations |> Enum.reduce(visited, &MapSet.put(&2, &1))}
  end
end

File.read!("input")
|> String.trim()
|> String.split("\n")
|> Enum.map(&String.split(&1, ","))
|> Enum.map(fn path -> Enum.map(path, &Path.parse_step/1) end)
|> Enum.map(&Path.trace/1)
|> (fn [wire1, wire2] ->
  MapSet.intersection(wire1, wire2)
end).()
|> Enum.map(fn {x, y} -> abs(x) + abs(y) end)
|> Enum.sort()
|> IO.inspect()
