defmodule Board do
  def new(), do: {0, 1, %{0 => 3, 1 => 7}}

  def step({elf1, elf2, recipes}) do
    r1 = recipes[elf1]
    r2 = recipes[elf2]

    recipes =
      new_scores(r1 + r2)
      |> Enum.reduce(recipes, fn score, recipes ->
        Map.put(recipes, map_size(recipes), score)
      end)

    {move(elf1, recipes), move(elf2, recipes), recipes}
  end

  def check({_, _, recipes}, sequence) do
    for i <- (map_size(recipes) - 10)..(map_size(recipes) - 1) do
      recipes[i]
    end
    |> Enum.join()
    |> String.contains?(sequence)
  end

  def recipes({_, _, recipes}), do: recipes

  defp new_scores(total) do
    if total < 10, do: [total], else: [div(total, 10), rem(total, 10)]
  end

  defp move(elf, recipes) do
    to_move = recipes[elf] + 1
    rem(elf + to_move, map_size(recipes))
  end
end

sequence = "633601"

Board.new()
|> Stream.iterate(&Board.step/1)
|> Stream.with_index()
|> Enum.find(&Board.check(&1, sequence))
|> Board.recipes()
|> Enum.sort()
|> Enum.map(&elem(&1, 1))
|> Enum.map(&to_string/1)
|> Enum.join()
|> :binary.match(sequence)
|> IO.inspect()
