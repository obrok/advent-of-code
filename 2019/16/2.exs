defmodule FFT do
  def phase_tail(tail, acc \\ 0)
  def phase_tail([], _), do: []

  def phase_tail([element | rest], acc) do
    acc = rem(acc + element, 10)
    [acc | phase_tail(rest, acc)]
  end
end

numbers =
  File.read!("input")
  |> String.trim()
  |> String.graphemes()
  |> Enum.map(&String.to_integer/1)

offset =
  numbers
  |> Enum.take(7)
  |> Enum.join("")
  |> String.to_integer()

1..10000
|> Enum.flat_map(fn _ -> numbers end)
|> Enum.drop(offset)
|> Enum.reverse()
|> Stream.iterate(&FFT.phase_tail/1)
|> Enum.at(100)
|> Enum.reverse()
|> Enum.take(8)
|> Enum.join("")
|> IO.inspect()
