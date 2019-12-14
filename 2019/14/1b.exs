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

  def needed(_, target, target, quantity), do: quantity

  def needed(recipes, chemical, target, quantity) do
    recipes
    |> Enum.filter(fn {_, %{inputs: inputs}} -> inputs |> Enum.map(&elem(&1, 0)) |> Enum.any?(&(&1 == chemical)) end)
    |> Enum.map(fn {result, recipe} ->
      needed = needed(recipes, result, target, quantity)
      times_executed = div_ceil(needed, recipe.quantity)
      {_, input_per_execution} = Enum.find(recipe.inputs, fn {c, _} -> c == chemical end)
      input_per_execution * times_executed
    end)
    |> Enum.sum()
  end

  def div_ceil(a, b) when a < 0, do: -div_ceil(-a, b)
  def div_ceil(a, b), do: if(rem(a, b) == 0, do: div(a, b), else: div(a, b) + 1)
end

File.read!("input")
|> String.trim()
|> Reaction.parse()
|> Reaction.needed("ORE", "FUEL", 1)
|> IO.inspect()
