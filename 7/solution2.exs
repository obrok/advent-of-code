defmodule Steps do
  def simulate(steps, second \\ 0, workers \\ []) do
    next_step = steps |> Map.keys() |> Enum.filter(&(steps[&1] == [])) |> Enum.min(fn -> nil end)
    finished = Enum.find(workers, &match?({_, 0}, &1))

    cond do
      Enum.empty?(steps) and Enum.empty?(workers) ->
        second

      Enum.count(workers) < 5 and next_step ->
        simulate(Map.delete(steps, next_step), second, [{next_step, cost(next_step)} | workers])

      finished ->
        workers = Enum.reject(workers, &(&1 == finished))
        steps = complete_step(steps, elem(finished, 0))
        simulate(steps, second, workers)

      true ->
        simulate(steps, second + 1, workers |> Enum.map(fn {s, t} -> {s, t - 1} end))
    end
  end

  defp complete_step(steps, step) do
    steps
    |> Enum.map(fn {k, v} -> {k, Enum.reject(v, &(&1 == step))} end)
    |> Enum.into(%{})
  end

  defp cost(step) do
    [step] = to_charlist(step)
    60 + step - ?A + 1
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
|> Steps.simulate()
|> IO.inspect()
