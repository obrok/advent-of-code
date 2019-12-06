defmodule Orbit do
  def count(graph, name, depth, acc) do
    children =
      graph
      |> Map.get(name, [])
      |> Enum.reduce(acc, fn child, acc -> count(graph, child, depth + 1, acc) end)

    children + depth
  end
end

File.read!("input")
|> String.trim()
|> String.split("\n")
|> Enum.map(&String.split(&1, ")"))
|> Enum.group_by(&Enum.at(&1, 0), &Enum.at(&1, 1))
|> Orbit.count("COM", 0, 0)
|> IO.inspect()
