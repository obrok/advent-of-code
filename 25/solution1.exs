defmodule Constellation do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line |> String.split(",") |> Enum.map(&String.to_integer/1)
    end)
  end

  def build_constellations(points) do
    sets = points |> Enum.map(&{&1, &1}) |> Enum.into(%{})

    for p1 <- points, p2 <- points, p1 != p2, manhattan_dist(p1, p2) <= 3 do
      {p1, p2}
    end
    |> Enum.reduce(sets, fn {p1, p2}, sets ->
      merge(sets, p1, p2)
    end)
  end

  defp merge(sets, p1, p2) do
    {sets, p1} = tag(sets, p1)
    {sets, p2} = tag(sets, p2)
    Map.put(sets, p1, p2)
  end

  def tag(sets, p) do
    sets = shorten(sets, p)
    {sets, sets[p]}
  end

  defp shorten(sets, p) do
    if sets[p] == p do
      sets
    else
      sets = shorten(sets, sets[p])
      Map.put(sets, p, sets[sets[p]])
    end
  end

  def manhattan_dist(point1, point2) do
    point1
    |> Enum.zip(point2)
    |> Enum.map(fn {a, b} -> abs(a - b) end)
    |> Enum.sum()
  end
end

constellations =
  File.read!("input.txt")
  |> Constellation.parse()
  |> Constellation.build_constellations()

constellations
|> Map.keys()
|> Enum.map(&Constellation.tag(constellations, &1))
|> Enum.map(&elem(&1, 1))
|> Enum.uniq()
|> Enum.count()
|> IO.inspect()
