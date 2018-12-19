defmodule Lumber do
  @max 50

  def parse(input) do
    for {line, x} <- input |> String.split("\n", trim: true) |> Enum.with_index(),
        {char, y} <- line |> String.graphemes() |> Enum.with_index() do
      {{x, y}, char}
    end
    |> Enum.into(%{})
  end

  def step(lumber) do
    for x <- 0..@max, y <- 0..@max, into: %{} do
      case {lumber[{x, y}], count(lumber, {x, y}, "|"), count(lumber, {x, y}, "#")} do
        {nil, _, _} -> {nil, nil}
        {".", trees, _} when trees >= 3 -> {{x, y}, "|"}
        {"|", _, yards} when yards >= 3 -> {{x, y}, "#"}
        {"#", trees, yards} when trees >= 1 and yards >= 1 -> {{x, y}, "#"}
        {"#", _, _} -> {{x, y}, "."}
        {other, _, _} -> {{x, y}, other}
      end
    end
  end

  defp count(lumber, {x, y}, kind) do
    for i <- (x - 1)..(x + 1), j <- (y - 1)..(y + 1), i != x or j != y do
      if(lumber[{i, j}] == kind, do: 1, else: 0)
    end
    |> Enum.sum()
  end

  def score(lumber) do
    trees = lumber |> Map.values() |> Enum.count(&(&1 == "|"))
    yards = lumber |> Map.values() |> Enum.count(&(&1 == "#"))
    trees * yards
  end

  def draw(lumber) do
    for x <- 0..@max do
      for y <- 0..@max do
        IO.write(lumber[{x, y}])
      end

      IO.puts("")
    end

    IO.puts("")
  end
end

File.read!("input.txt")
|> Lumber.parse()
|> Stream.iterate(&Lumber.step/1)
|> Stream.map(&Lumber.score/1)
|> Stream.with_index()
|> Stream.each(&IO.inspect/1)
|> Stream.run()
|> IO.inspect()
