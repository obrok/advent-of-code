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

  def size({_, _, recipes}), do: map_size(recipes)

  def score({_, _, recipes}, skip) do
    for i <- skip..(skip + 9) do
      recipes[i]
    end
    |> Enum.join()
  end

  defp new_scores(total) do
    if total < 10, do: [total], else: [div(total, 10), rem(total, 10)]
  end

  defp move(elf, recipes) do
    to_move = recipes[elf] + 1
    rem(elf + to_move, map_size(recipes))
  end
end

steps = 633_601
# steps = 2018

Board.new()
|> Stream.iterate(&Board.step/1)
|> Stream.drop_while(&(Board.size(&1) < steps + 10))
|> Enum.take(1)
|> hd()
|> Board.score(steps)
|> IO.inspect()
