defmodule Water do
  def parse(input) do
    map =
      input
      |> String.split("\n", trim: true)
      |> Enum.flat_map(&parse_block/1)
      |> Enum.map(&{&1, :clay})
      |> Enum.into(%{})

    {min_x, max_x} = map |> Map.keys() |> Enum.map(&elem(&1, 0)) |> Enum.min_max()
    {min_y, max_y} = map |> Map.keys() |> Enum.map(&elem(&1, 1)) |> Enum.min_max()

    %{map: map, min_x: min_x, max_x: max_x, min_y: min_y, max_y: max_y}
  end

  def parse_block(line) do
    cond do
      res = Regex.run(~r/x=(\d+), y=(\d+)..(\d+)/, line) ->
        [_, x, y1, y2] = res
        Enum.map(String.to_integer(y1)..String.to_integer(y2), &{String.to_integer(x), &1})

      res = Regex.run(~r/y=(\d+), x=(\d+)..(\d+)/, line) ->
        [_, y, x1, x2] = res
        Enum.map(String.to_integer(x1)..String.to_integer(x2), &{&1, String.to_integer(y)})
    end
  end

  def fill(water, start \\ {500, 0}, ignore_flow \\ false)

  def fill(water, {x, y}, ignore_flow) do
    cond do
      y > water.max_y ->
        water

      not ignore_flow and flow?(water, {x, y}) ->
        water

      fall?(water, {x, y}) ->
        water
        |> put_in([:map, {x, y}], :flow)
        |> fill({x, y + 1})
        |> fill_if_hard({x, y})

      true ->
        case bounds(water, {x, y}) do
          {:hard, x1, x2} ->
            Enum.reduce(x1..x2, water, &put_in(&2, [:map, {&1, y}], :water))

          {:fall, x1, x2} ->
            x1..x2
            |> Enum.reduce(water, &put_in(&2, [:map, {&1, y}], :flow))
            |> fill_if_fall({x1, y})
            |> fill_if_fall({x2, y})
        end
    end
  end

  defp fill_if_hard(water, start) do
    if flow?(water, start) and not fall?(water, start), do: fill(water, start, true), else: water
  end

  defp fill_if_fall(water, start) do
    if fall?(water, start), do: fill(water, start, true), else: water
  end

  defp bounds(water, {x, y}) do
    bound_type = fn x ->
      cond do
        hard?(water, {x, y}) -> {:hard, x}
        fall?(water, {x, y}) -> {:fall, x}
        true -> nil
      end
    end

    left = x..(water.min_x - 1) |> Stream.map(bound_type) |> Enum.find(& &1)
    right = x..(water.max_x + 1) |> Stream.map(bound_type) |> Enum.find(& &1)

    case {left, right} do
      {{:hard, left}, {:hard, right}} -> {:hard, left + 1, right - 1}
      {{:hard, left}, {:fall, right}} -> {:fall, left + 1, right}
      {{:fall, left}, {:hard, right}} -> {:fall, left, right - 1}
      {{:fall, left}, {:fall, right}} -> {:fall, left, right}
    end
  end

  defp fall?(water, {x, y}), do: !hard?(water, {x, y + 1})

  defp flow?(water, pos), do: water.map[pos] == :flow

  defp hard?(water, pos), do: water.map[pos] in [:clay, :water]

  def count(water) do
    for y <- water.min_y..water.max_y, x <- (water.min_x - 1)..(water.max_x + 1) do
      {x, y}
    end
    |> Enum.count(&has_water?(water, &1))
  end

  defp has_water?(water, pos), do: water.map[pos] in [:water]

  def draw(water) do
    for y <- 0..water.max_y do
      for x <- (water.min_x - 1)..(water.max_x + 1) do
        if x == 500 and y == 0 do
          IO.write("+")
        else
          case water.map[{x, y}] do
            nil -> IO.write(" ")
            :clay -> IO.write("#")
            :flow -> IO.write("|")
            :water -> IO.write("~")
          end
        end
      end

      IO.puts("")
    end

    IO.puts("")
  end
end

File.read!("input.txt")
|> Water.parse()
|> Water.fill()
|> Water.count()
|> IO.inspect()
