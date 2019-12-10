defmodule Asteroid do
  def visible(from, asteroids) do
    asteroids
    |> Map.keys()
    |> Enum.filter(&(asteroids[&1] == "#" && &1 != from))
    |> Enum.count(&visible?(&1, from, asteroids))
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
  |> Enum.flat_map(fn {row, x} ->
    Enum.map(row, fn {item, y} ->
      {{x, y}, item}
    end)
  end)
  |> Map.new()

asteroids
|> Map.keys()
|> Enum.filter(&(asteroids[&1] == "#"))
|> Enum.map(&Asteroid.visible(&1, asteroids))
|> Enum.max()
|> IO.inspect()
