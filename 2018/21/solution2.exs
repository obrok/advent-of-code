defmodule Emulator do
  use Bitwise

  def big_step(r5) do
    r4 = r5 ||| 0b10000000000000000
    r5 = 3_935_295

    r4
    |> Stream.iterate(&div(&1, 256))
    |> Enum.take_while(&(&1 > 0))
    |> Enum.reduce(r5, &step(&1, &2))
  end

  def step(r4, r5) do
    r5 = r5 + (r4 &&& 0b11111111)
    r5 = r5 &&& 0b111111111111111111111111
    r5 = r5 * 65899
    r5 = r5 &&& 0b111111111111111111111111
    r5
  end
end

0
|> Stream.iterate(&Emulator.big_step/1)
|> Stream.transform(MapSet.new(), fn r5, seen ->
  if r5 in seen do
    {:halt, seen}
  else
    {[r5], MapSet.put(seen, r5)}
  end
end)
|> Enum.to_list()
|> List.last()
|> IO.inspect()
