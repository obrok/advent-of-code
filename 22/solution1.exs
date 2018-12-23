defmodule Cave do
  @magic_number 20183
  @magic_number_x 16807
  @magic_number_y 48271

  def erosion_levels(depth, target, max_x, max_y) do
    for x <- 0..max_x, y <- 0..max_y do
      {x, y}
    end
    |> Enum.reduce(%{}, fn pos, map ->
      Map.put(map, pos, erosion_level(pos, map, target, depth))
    end)
  end

  def score(map) do
    map
    |> Map.values()
    |> Enum.map(&rem(&1, 3))
    |> Enum.sum()
  end

  defp erosion_level({0, 0}, _map, _target, depth), do: rem(depth, @magic_number)
  defp erosion_level(target, _map, target, depth), do: rem(depth, @magic_number)

  defp erosion_level({x, 0}, _map, _target, depth),
    do: rem(x * @magic_number_x + depth, @magic_number)

  defp erosion_level({0, y}, _map, _target, depth),
    do: rem(y * @magic_number_y + depth, @magic_number)

  defp erosion_level({x, y}, map, _target, depth),
    do: rem(map[{x - 1, y}] * map[{x, y - 1}] + depth, @magic_number)
end

depth = 3066
target = {13, 726}

Cave.erosion_levels(depth, target, elem(target, 0), elem(target, 1))
|> Cave.score()
|> IO.inspect()
