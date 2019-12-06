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

  def overlap?(c1, c2) do
    for i <- c1.left..(c1.left + c1.width - 1),
        j <- c1.top..(c1.top + c1.height - 1) do
      {i, j}
    end
    |> Enum.any?(fn {i, j} -> member?(c2, i, j) end)
  end
end

claims =
  File.read!("input.txt")
  |> String.split("\n")
  |> Enum.filter(&String.contains?(&1, "@"))
  |> Enum.map(&Claim.parse/1)

claims
|> Enum.find(fn c1 ->
  IO.inspect(c1.id)

  Enum.all?(claims, fn c2 ->
    c2 == c1 or not Claim.overlap?(c1, c2)
  end)
end)
|> IO.inspect()
