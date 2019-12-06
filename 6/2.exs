defmodule Graph do
  def to_root(parent, node, acc \\ []) do
    if node == "COM" do
      acc
    else
      to_root(parent, parent[node], [node | acc])
    end
  end

  def remove_common_prefix([a | rest1], [a | rest2]), do: remove_common_prefix(rest1, rest2)
  def remove_common_prefix(a, b), do: {a, b}
end

File.read!("input")
|> String.trim()
|> String.split("\n")
|> Enum.map(&String.split(&1, ")"))
|> Map.new(fn [parent, child] -> {child, parent} end)
|> (fn parent ->
      p1 = Graph.to_root(parent, "YOU")
      p2 = Graph.to_root(parent, "SAN")
      {p1, p2} = Graph.remove_common_prefix(p1, p2)
      length(p1) + length(p2) - 2
    end).()
|> IO.inspect()
