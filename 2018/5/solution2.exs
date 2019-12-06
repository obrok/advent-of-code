defmodule Polymer do
  def reduce([c1, c2 | rest]) do
    if c1 != c2 and String.downcase(c1) == String.downcase(c2) do
      reduce(rest)
    else
      case reduce([c2 | rest]) do
        result = [^c2 | _] -> [c1 | result]
        other -> reduce([c1 | other])
      end
    end
  end

  def reduce(other), do: other
end

polymer = File.read!("input.txt") |> String.trim() |> String.codepoints()

?a..?z
|> Enum.map(&to_string([&1]))
|> Enum.map(fn letter -> Enum.reject(polymer, &(String.downcase(&1) == letter)) end)
|> Enum.map(&Polymer.reduce/1)
|> Enum.map(&length/1)
|> Enum.min()
|> IO.inspect()
