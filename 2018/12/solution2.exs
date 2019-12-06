defmodule Cell do
  def step(state, rules) do
    {min, max} = state |> Map.keys() |> Enum.min_max()

    for i <- (min - 2)..(max + 2), into: %{} do
      neighborhood = (i - 2)..(i + 2) |> Enum.map(&Map.get(state, &1, ".")) |> Enum.join()
      {i, rules[neighborhood]}
    end
  end

  def representation(state) do
    state
    |> Enum.sort()
    |> Enum.map(&elem(&1, 1))
    |> Enum.join()
    |> String.trim(".")
  end

  def value(state) do
    state
    |> Enum.filter(fn {_pos, cell} -> cell == "#" end)
    |> Enum.map(fn {pos, _cell} -> pos end)
    |> Enum.sum()
  end
end

initial_state =
  "##.####..####...#.####..##.#..##..#####.##.#..#...#.###.###....####.###...##..#...##.#.#...##.##.."

rules = %{
  "##.##" => "#",
  "....#" => ".",
  ".#.#." => "#",
  "..###" => ".",
  "##..." => "#",
  "#####" => ".",
  "###.#" => "#",
  ".##.." => ".",
  "..##." => ".",
  "...##" => "#",
  "####." => ".",
  "###.." => ".",
  ".####" => "#",
  "#...#" => "#",
  "....." => ".",
  "..#.." => ".",
  "#..##" => ".",
  "#.#.#" => "#",
  ".#.##" => "#",
  ".###." => ".",
  "##..#" => ".",
  ".#..." => "#",
  ".#..#" => "#",
  "...#." => ".",
  "#.#.." => ".",
  "#...." => ".",
  "##.#." => ".",
  "#.###" => ".",
  ".##.#" => ".",
  "#..#." => "#",
  "..#.#" => ".",
  "#.##." => "#"
}

0..(String.length(initial_state) - 1)
|> Enum.zip(String.graphemes(initial_state))
|> Enum.into(%{})
|> Stream.iterate(&Cell.step(&1, rules))
|> Stream.chunk_every(2, 1)
|> Stream.with_index()
|> Stream.drop_while(fn {[state, next_state], _i} ->
  Cell.representation(state) != Cell.representation(next_state)
end)
|> Enum.at(0)
|> (fn {[state, next_state], i} ->
      change = Cell.value(next_state) - Cell.value(state)
      Cell.value(state) + (50_000_000_000 - i) * change
    end).()
|> IO.inspect()
