defmodule Distance do
  def closest(point, points) do
    closest = Enum.min_by(points, &distance(&1, point))
    closest_distance = distance(point, closest)

    points
    |> Enum.filter(&(distance(point, &1) == closest_distance))
    |> case do
      [single] -> single
      _ -> nil
    end
  end

  def distance({x1, y1}, {x2, y2}), do: abs(x1 - x2) + abs(y1 - y2)
end

points =
  File.read!("input.txt")
  |> String.split("\n", trim: true)
  |> Enum.map(&String.split(&1, ", "))
  |> Enum.map(fn [a, b] -> {String.to_integer(a), String.to_integer(b)} end)

{min_x, max_x} = points |> Enum.map(&elem(&1, 0)) |> Enum.min_max()
{min_y, max_y} = points |> Enum.map(&elem(&1, 1)) |> Enum.min_max()

for i <- min_x..max_x, j <- min_y..max_y do
  {i, j}
end
|> Enum.count(fn point ->
  points |> Enum.map(&Distance.distance(point, &1)) |> Enum.sum() < 10000
end)
|> IO.inspect()
