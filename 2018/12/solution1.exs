defmodule Cell do
  def step(state, rules) do
    {min, max} = state |> Map.keys() |> Enum.min_max()

    for i <- (min - 2)..(max + 2), into: %{} do
      neighborhood = (i - 2)..(i + 2) |> Enum.map(&Map.get(state, &1, ".")) |> Enum.join()

      {i, rules[neighborhood]}
    end
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

state =
  0..(String.length(initial_state) - 1)
  |> Enum.zip(String.graphemes(initial_state))
  |> Enum.into(%{})

Enum.reduce(1..20, state, fn _, state -> Cell.step(state, rules) end)
|> Enum.filter(fn {_pos, cell} -> cell == "#" end)
|> Enum.map(fn {pos, _cell} -> pos end)
|> Enum.sum()
|> IO.inspect()
