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

File.read!("input.txt")
|> String.trim()
|> String.codepoints()
|> Polymer.reduce()
|> length()
|> IO.inspect()
