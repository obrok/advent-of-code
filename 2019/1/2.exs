defmodule Fuel do
  def amount(mass) do
    fuel = div(mass, 3) - 2

    if fuel <= 0 do
      0
    else
      fuel + amount(fuel)
    end
  end
end

File.read!("input")
|> String.trim()
|> String.split()
|> Enum.map(&String.to_integer/1)
|> Enum.map(&Fuel.amount/1)
|> Enum.sum()
|> IO.inspect()
