defmodule Moon do
  def parse(string) do
    position =
      ~r/<x=(?<x>[^,]+), y=(?<y>[^,]+), z=(?<z>[^>]+)>/
      |> Regex.named_captures(string)
      |> (fn captures -> [captures["x"], captures["y"], captures["z"]] end).()
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()

    %{position: position, velocity: {0, 0, 0}}
  end

  def step(moons) do
    moons
    |> Enum.map(&apply_gravity(&1, moons))
    |> Enum.map(&apply_velocity/1)
  end

  def energy(%{position: {x, y, z}, velocity: {vx, vy, vz}}) do
    (abs(x) + abs(y) + abs(z)) * (abs(vx) + abs(vy) + abs(vz))
  end

  def apply_gravity(moon, moons) do
    velocity =
      Enum.reduce(moons, moon.velocity, fn %{position: position}, {x, y, z} ->
        apply_one_gravity(moon.position, position, {x, y, z})
      end)

    %{moon | velocity: velocity}
  end

  def apply_one_gravity({x1, y1, z1}, {x2, y2, z2}, {vx, vy, vz}) do
    {vx + direction(x1, x2), vy + direction(y1, y2), vz + direction(z1, z2)}
  end

  def direction(x1, x2) when x2 > x1, do: 1
  def direction(x1, x2) when x2 < x1, do: -1
  def direction(_, _), do: 0

  def apply_velocity(%{position: {x, y, z}, velocity: {vx, vy, vz}}) do
    %{position: {x + vx, y + vy, z + vz}, velocity: {vx, vy, vz}}
  end
end

File.read!("input")
|> String.trim()
|> String.split("\n")
|> Enum.map(&Moon.parse/1)
|> Stream.iterate(&Moon.step/1)
|> Enum.at(1000)
|> Enum.map(&Moon.energy/1)
|> Enum.sum()
|> IO.inspect()
