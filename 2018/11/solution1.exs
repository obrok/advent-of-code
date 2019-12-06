grid_serial = 2694

for x <- 1..298, y <- 1..298 do
  {x, y}
end
|> Enum.max_by(fn {x, y} ->
  for i <- x..(x + 2), j <- y..(y + 2) do
    rack_id = i + 10
    power = rack_id * j
    power = power + grid_serial
    power = power * rack_id
    power = trunc(power / 100)
    power = rem(power, 10)
    power - 5
  end
  |> Enum.sum()
end)
|> IO.inspect()
