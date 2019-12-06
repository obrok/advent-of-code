defmodule Grid do
  @grid_serial 2694

  def cache_power(square = {x, y, size}, cache) do
    cond do
      cache[square] -> cache[square]
      size == 1 -> power(x, y)
      true -> cache_power({x, y, size - 1}, cache) + extend({x, y, size})
    end
  end

  def extend({x, y, size}) do
    (Enum.map(x..(x + size - 1), &power(&1, y + size - 1)) |> Enum.sum()) +
      (Enum.map(y..(y + size - 1), &power(x + size - 1, &1)) |> Enum.sum()) -
      power(x + size - 1, y + size - 1)
  end

  def power(x, y) do
    rack_id = x + 10
    power = rack_id * y
    power = power + @grid_serial
    power = power * rack_id
    power = trunc(power / 100)
    power = rem(power, 10)
    power - 5
  end
end

total_size = 300

for size <- 1..total_size, x <- 1..(total_size - size + 1), y <- 1..(total_size - size + 1) do
  {x, y, size}
end
|> Enum.reduce(%{}, fn square, cache ->
  Map.put(cache, square, Grid.cache_power(square, cache))
end)
|> Enum.max_by(fn {_, v} -> v end)
|> IO.inspect()
