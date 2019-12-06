defmodule Nanobot do
  def parse(line) do
    [_, x, y, z, r] = Regex.run(~r/<(-?\d+),(-?\d+),(-?\d+)>, r=(-?\d+)/, line)
    [x, y, z, r] = Enum.map([x, y, z, r], &String.to_integer/1)
    %{x: x, y: y, z: z, r: r}
  end

  def manhattan_dist(bot1, bot2) do
    abs(bot1.x - bot2.x) + abs(bot1.y - bot2.y) + abs(bot1.z - bot2.z)
  end
end

nanobots =
  File.read!("input.txt")
  |> String.split("\n", trim: true)
  |> Enum.map(&Nanobot.parse/1)

strongest = Enum.max_by(nanobots, & &1.r)

nanobots
|> MapSet.new()
|> Enum.count(fn nanobot ->
  Nanobot.manhattan_dist(strongest, nanobot) <= strongest.r
end)
|> IO.inspect()
