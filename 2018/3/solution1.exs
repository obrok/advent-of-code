defmodule Claim do
  def parse(text) do
    [_, id, left, top, width, height] = Regex.run(~r/#(\d*) @ (\d*),(\d*): (\d*)x(\d*)/, text)

    %{
      id: String.to_integer(id),
      left: String.to_integer(left),
      top: String.to_integer(top),
      width: String.to_integer(width),
      height: String.to_integer(height)
    }
  end

  def member?(claim, i, j) do
    i >= claim.left and i < claim.left + claim.width and j >= claim.top and
      j < claim.top + claim.height
  end
end

claims =
  File.read!("input.txt")
  |> String.split("\n")
  |> Enum.filter(&String.contains?(&1, "@"))
  |> Enum.map(&Claim.parse/1)

for i <- 1..1000 do
  for j <- 1..1000 do
    {i, j}
  end
end
|> :lists.flatten()
|> Enum.count(fn {i, j} ->
  IO.inspect({i, j})

  claims
  |> Stream.filter(&Claim.member?(&1, i, j))
  |> Enum.take(2)
  |> case do
    [_, _ | _] -> true
    _ -> false
  end
end)
|> IO.inspect()
