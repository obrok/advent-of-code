defmodule Point do
  def parse(string) do
    [_ | rest] = Regex.run(~r/<(.*?),(.*?)>.*?<(.*?),(.*?)>/, string)
    [x, y, vx, vy] = rest |> Enum.map(&String.trim/1) |> Enum.map(&String.to_integer/1)

    %{position: {x, y}, velocity: {vx, vy}}
  end

  def step(points) do
    Enum.map(points, fn %{position: {x, y}, velocity: {vx, vy}} ->
      %{position: {x + vx, y + vy}, velocity: {vx, vy}}
    end)
  end

  def focused?(points) do
    {{min_x, max_x}, {min_y, max_y}} = min_max(points)
    abs(min_x - max_x) <= 69 and abs(min_y - max_y) <= 9
  end

  defp min_max(points) do
    {points |> Enum.map(fn %{position: {x, _y}} -> x end) |> Enum.min_max(),
     points |> Enum.map(fn %{position: {_x, y}} -> y end) |> Enum.min_max()}
  end
end

File.read!("input.txt")
|> String.split("\n", trim: true)
|> Enum.map(&Point.parse/1)
|> Stream.iterate(&Point.step/1)
|> Stream.take_while(&(not Point.focused?(&1)))
|> Enum.count()
|> IO.inspect()
