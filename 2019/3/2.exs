defmodule Path do
  def parse_step(step) do
    captures = Regex.named_captures(~r/(?<dir>U|D|L|R)(?<dist>.*)/, step)
    {String.to_atom(captures["dir"]), String.to_integer(captures["dist"])}
  end

  def trace(steps) do
    {_, _, visited} = Enum.reduce(steps, {0, {0, 0}, %{}}, fn step, {step_no, location, visited} ->
      trace_one(step, step_no, location, visited)
    end)
    visited
  end

  def trace_one(step, step_no, {x, y}, visited) do
    locations = case step do
      {:U, distance} -> y..(y + distance) |> Enum.map(&{x, &1})
      {:D, distance} -> y..(y - distance) |> Enum.map(&{x, &1})
      {:L, distance} -> x..(x - distance) |> Enum.map(&{&1, y})
      {:R, distance} -> x..(x + distance) |> Enum.map(&{&1, y})
    end
    |> Enum.with_index()
    |> Enum.map(fn {loc, index} -> {loc, step_no + index} end)

    {
      locations |> Enum.reverse() |> hd() |> elem(1),
      locations |> Enum.reverse() |> hd() |> elem(0),
      locations |> Enum.reduce(visited, fn {loc, step_no}, acc -> Map.put_new(acc, loc, step_no) end)
    }
  end
end

File.read!("input")
|> String.trim()
|> String.split("\n")
|> Enum.map(&String.split(&1, ","))
|> Enum.map(fn path -> Enum.map(path, &Path.parse_step/1) end)
|> Enum.map(&Path.trace/1)
|> (fn [path1, path2] ->
  path1
  |> Map.keys()
  |> Enum.filter(&path2[&1])
  |> Enum.map(&path1[&1] + path2[&1])
  |> Enum.sort()
end).()
|> IO.inspect()
