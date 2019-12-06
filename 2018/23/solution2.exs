defmodule PriorityQueue do
  def empty(), do: :empty

  def singleton(key, value), do: {key, value, :empty, :empty, 1}

  def pop_min(:empty), do: :empty
  def pop_min({_, v, l, r, _}), do: {v, merge(l, r)}

  def push(queue, key, value), do: merge(queue, singleton(key, value))

  defp rank(:empty), do: 0
  defp rank({_, _, _, _, rank}), do: rank

  defp merge(:empty, tree), do: tree
  defp merge(tree, :empty), do: tree

  defp merge(tree1 = {k1, _, _, _, _}, tree2 = {k2, _, _, _, _}) when k1 > k2,
    do: merge(tree2, tree1)

  defp merge({k, v, l, r, _}, tree2) do
    merged = merge(r, tree2)

    if rank(l) >= rank(merged) do
      {k, v, l, merged, rank(l) + 1}
    else
      {k, v, merged, l, rank(merged) + 1}
    end
  end
end

defmodule Nanobot do
  def parse(line) do
    [_, x, y, z, r] = Regex.run(~r/<(-?\d+),(-?\d+),(-?\d+)>, r=(-?\d+)/, line)
    [x, y, z, r] = Enum.map([x, y, z, r], &String.to_integer/1)
    %{x: x, y: y, z: z, r: r}
  end

  def best_location(bots) do
    x = bots |> Enum.map(& &1.x) |> Enum.min_max()
    y = bots |> Enum.map(& &1.y) |> Enum.min_max()
    z = bots |> Enum.map(& &1.z) |> Enum.min_max()

    best_location(bots, PriorityQueue.singleton({0, 0}, %{x: x, y: y, z: z}))
  end

  defp best_location(bots, queue, best \\ 0, best_regions \\ [])

  defp best_location(_, :empty, _best, best_regions), do: best_regions

  defp best_location(bots, queue, best, best_regions) do
    {region, queue} = PriorityQueue.pop_min(queue)

    middle = middle(region)

    min = Enum.count(bots, &in_range?(&1, middle))
    max = Enum.count(bots, &in_range_of_region?(&1, region))

    best_regions =
      cond do
        min > best and min != max -> []
        min >= best and min == max -> [region | best_regions]
        true -> best_regions
      end

    queue =
      if min != max && max >= best do
        region |> subregions() |> Enum.reduce(queue, &PriorityQueue.push(&2, {-max, -min}, &1))
      else
        queue
      end

    best = max(min, best)

    best_location(bots, queue, best, best_regions)
  end

  defp subregions(%{x: {x1, x2}, y: {y1, y2}, z: {z1, z2}}) do
    mid_x = div(x1 + x2, 2)
    mid_y = div(y1 + y2, 2)
    mid_z = div(z1 + z2, 2)

    [
      %{x: {x1, mid_x}, y: {y1, mid_y}, z: {z1, mid_z}},
      %{x: {mid_x + 1, x2}, y: {y1, mid_y}, z: {z1, mid_z}},
      %{x: {x1, mid_x}, y: {mid_y + 1, y2}, z: {z1, mid_z}},
      %{x: {mid_x + 1, x2}, y: {mid_y + 1, y2}, z: {z1, mid_z}},
      %{x: {x1, mid_x}, y: {y1, mid_y}, z: {mid_z + 1, z2}},
      %{x: {mid_x + 1, x2}, y: {y1, mid_y}, z: {mid_z + 1, z2}},
      %{x: {x1, mid_x}, y: {mid_y + 1, y2}, z: {mid_z + 1, z2}},
      %{x: {mid_x + 1, x2}, y: {mid_y + 1, y2}, z: {mid_z + 1, z2}}
    ]
    |> Enum.reject(fn %{x: {x1, x2}, y: {y1, y2}, z: {z1, z2}} ->
      x1 > x2 or y1 > y2 or z1 > z2
    end)
  end

  defp in_range_of_region?(bot, region) do
    cond do
      between?(bot.x, region.x) and region.x != {0, 0} ->
        in_range_of_region?(%{bot | x: 0}, %{region | x: {0, 0}})

      between?(bot.y, region.y) and region.y != {0, 0} ->
        in_range_of_region?(%{bot | y: 0}, %{region | y: {0, 0}})

      between?(bot.z, region.z) and region.z != {0, 0} ->
        in_range_of_region?(%{bot | z: 0}, %{region | z: {0, 0}})

      true ->
        region |> corners() |> Enum.any?(&in_range?(bot, &1))
    end
  end

  defp between?(v, {v1, v2}), do: v >= v1 and v <= v2

  def in_range?(bot, {x, y, z}) do
    abs(bot.x - x) + abs(bot.y - y) + abs(bot.z - z) <= bot.r
  end

  defp middle(%{x: {x1, x2}, y: {y1, y2}, z: {z1, z2}}) do
    {div(x1 + x2, 2), div(y1 + y2, 2), div(z1 + z2, 2)}
  end

  defp corners(%{x: {x1, x2}, y: {y1, y2}, z: {z1, z2}}) do
    for x <- [x1, x2], y <- [y1, y2], z <- [z1, z2], do: {x, y, z}
  end
end

[%{x: {x, _}, y: {y, _}, z: {z, _}}] =
  File.read!("input.txt")
  |> String.split("\n", trim: true)
  |> Enum.map(&Nanobot.parse/1)
  |> Nanobot.best_location()

IO.inspect(x + y + z)
