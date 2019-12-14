defmodule Reaction do
  def parse(input) do
    input
    |> String.split("\n")
    |> Map.new(fn line ->
      [inputs, result] = String.split(line, " => ")
      inputs = inputs |> String.split(", ") |> Enum.map(&parse_chemical/1)
      {result, result_quantity} = parse_chemical(result)
      {result, %{inputs: inputs, quantity: result_quantity}}
    end)
  end

  def parse_chemical(chemical) do
    [quantity, name] = String.split(chemical, " ")
    {name, String.to_integer(quantity)}
  end

  def ore_for(chemicals, chemical, quantity) do
    %{chemical => quantity}
    |> Stream.iterate(fn needed ->
      {chemical, quantity} = needed |> Enum.find(fn {k, v} -> k != "ORE" && (v > 0 || -v >= chemicals[k].quantity) end)

      recipe = chemicals[chemical]
      times_produced = div_ceil(quantity, recipe.quantity)
      needed = Map.update!(needed, chemical, &(&1 - times_produced * recipe.quantity))

      Enum.reduce(chemicals[chemical].inputs, needed, fn {chemical, quantity}, needed ->
        Map.update(needed, chemical, quantity * times_produced, &(&1 + quantity * times_produced))
      end)
    end)
    |> Enum.find(&(!Enum.any?(&1, fn {k, v} -> k != "ORE" && (v > 0 || -v >= chemicals[k].quantity) end)))
    |> (fn needed -> needed["ORE"] end).()
  end

  def div_ceil(a, b) when a < 0, do: -div_ceil(-a, b)
  def div_ceil(a, b), do: if(rem(a, b) == 0, do: div(a, b), else: div(a, b) + 1)
end

reactions =
  File.read!("input")
  |> String.trim()
  |> Reaction.parse()

{1, 1_000_000_000_000}
|> Stream.iterate(fn {lower, upper} ->
  mid = div(upper + lower, 2)

  if Reaction.ore_for(reactions, "FUEL", mid) <= 1_000_000_000_000 do
    {mid, upper}
  else
    {lower, mid}
  end
end)
|> Enum.find(fn {lower, upper} -> upper - lower <= 1 end)
|> elem(0)
|> IO.inspect()
