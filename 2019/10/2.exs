defmodule Asteroid do
  def visible(from, asteroids) do
    asteroids
    |> Map.keys()
    |> Enum.filter(&(asteroids[&1] == "#" && &1 != from))
    |> Enum.filter(&visible?(&1, from, asteroids))
  end

  def visible?({to_x, to_y}, {from_x, from_y}, asteroids) do
    diff_x = to_x - from_x
    diff_y = to_y - from_y

    gcd = gcd(abs(diff_x), abs(diff_y))

    {move_x, move_y} =
      case {diff_x, diff_y} do
        {0, _} -> {0, div(diff_y, abs(diff_y))}
        {_, 0} -> {div(diff_x, abs(diff_x)), 0}
        {_, _} -> {div(diff_x, gcd), div(diff_y, gcd)}
      end

    {from_x, from_y}
    |> Stream.iterate(fn {x, y} -> {x + move_x, y + move_y} end)
    |> Stream.drop(1)
    |> Stream.take_while(&(&1 != {to_x, to_y}))
    |> Enum.any?(&(asteroids[&1] == "#"))
    |> Kernel.not()
  end

  def gcd(x, 0), do: x
  def gcd(x, y), do: gcd(y, rem(x, y))
end

asteroids =
  File.read!("input")
  |> String.trim()
  |> String.split("\n")
  |> Enum.map(&String.graphemes/1)
  |> Enum.map(&Enum.with_index/1)
  |> Enum.with_index()
  |> Enum.flat_map(fn {row, y} ->
    Enum.map(row, fn {item, x} ->
      {{x, y}, item}
    end)
  end)
  |> Map.new()

center =
  {center_x, center_y} =
  asteroids
  |> Map.keys()
  |> Enum.filter(&(asteroids[&1] == "#"))
  |> Enum.max_by(&Enum.count(Asteroid.visible(&1, asteroids)))

Asteroid.visible(center, asteroids)
|> Enum.sort_by(fn {x, y} ->
  case :math.atan2(x - center_x, y - center_y) do
    angle when angle >= 0 -> {0, angle}
    angle -> {1, -angle}
  end
end)
|> Enum.at(199)
|> IO.inspect()
