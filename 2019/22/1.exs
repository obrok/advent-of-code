defmodule Deck do
  def shuffle(deck, "deal into new stack"), do: Enum.reverse(deck)

  def shuffle(deck, "cut " <> number) do
    number = String.to_integer(number)
    cut_point = if number < 0, do: length(deck) + number, else: number
    Enum.drop(deck, cut_point) ++ Enum.take(deck, cut_point)
  end

  def shuffle(deck, "deal with increment " <> number) do
    number = String.to_integer(number)
    size = length(deck)

    {_, result} = Enum.reduce(deck, {0, %{}}, fn card, {pos, result} ->
      {rem(pos + number, size), Map.put(result, pos, card)}
    end)
    Enum.map(0..(size - 1), &result[&1])
  end
end

File.read!("input")
|> String.trim()
|> String.split("\n")
|> Enum.reduce(0..10006 |> Enum.to_list(), &Deck.shuffle(&2, &1))
|> Enum.find_index(& &1 == 2019)
|> IO.inspect()
