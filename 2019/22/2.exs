defmodule Shuffle do
  def x(), do: 6_299_113_414_412
  def y(), do: 48_986_675_035_865
  def n(), do: 119_315_717_514_047

  def shuffle(k), do: rem(k * x() + y(), n())

  def shuffle(k, times), do: rem(k * pow(x(), times) + y() * sum_pows(x(), times), n())

  def sum_pows(_, 1), do: 1

  def sum_pows(x, p) do
    if rem(p, 2) == 0 do
      smaller = sum_pows(x, div(p, 2))
      rem(pow(x, div(p, 2)) * smaller + smaller, n())
    else
      rem(x * sum_pows(x, p - 1) + 1, n())
    end
  end

  def pow(k, 1), do: k

  def pow(k, p) do
    if rem(p, 2) == 0 do
      smaller = pow(k, div(p, 2))
      rem(smaller * smaller, n())
    else
      rem(k * pow(k, p - 1), n())
    end
  end
end

start = 2020
Shuffle.shuffle(start, Shuffle.n() - 101_741_582_076_661 - 1) |> IO.inspect()
