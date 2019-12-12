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

  def count_states(states, selector) do
    states
    |> Enum.map(&Enum.map(&1, fn moon -> {selector.(moon.position), selector.(moon.velocity)} end))
    |> Enum.into(MapSet.new())
    |> Enum.count()
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

defmodule LCM do
  def lcm(x, y), do: div(x * y, gcd(x, y))

  def gcd(x, 0), do: x
  def gcd(x, y), do: gcd(y, rem(x, y))
end

states =
  File.read!("input")
  |> String.trim()
  |> String.split("\n")
  |> Enum.map(&Moon.parse/1)
  |> Stream.iterate(&Moon.step/1)
  |> Enum.take(400_000)

x_states = Moon.count_states(states, &elem(&1, 0))
y_states = Moon.count_states(states, &elem(&1, 1))
z_states = Moon.count_states(states, &elem(&1, 2))
x_states |> LCM.lcm(y_states) |> LCM.lcm(z_states) |> IO.inspect()
