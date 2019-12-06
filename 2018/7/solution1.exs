defmodule Steps do
  def assemble(steps) do
    if Enum.empty?(steps) do
      []
    else
      next_step = steps |> Map.keys() |> Enum.filter(&(steps[&1] == [])) |> Enum.min()

      steps =
        steps
        |> Enum.reject(fn {k, _v} -> k == next_step end)
        |> Enum.map(fn {k, v} -> {k, Enum.reject(v, &(&1 == next_step))} end)
        |> Enum.into(%{})

      [next_step | assemble(steps)]
    end
  end
end

File.read!("input.txt")
|> String.split("\n", trim: true)
|> Enum.map(fn line ->
  [_, a, b] = Regex.run(~r/Step (.) .* step (.)/, line)
  {b, a}
end)
|> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
|> (fn steps ->
      steps
      |> Map.values()
      |> :lists.flatten()
      |> Enum.reduce(steps, &Map.put_new(&2, &1, []))
    end).()
|> Steps.assemble()
|> Enum.join("")
|> IO.puts()
