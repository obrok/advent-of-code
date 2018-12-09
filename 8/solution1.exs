defmodule Tree do
  def build([]), do: raise("Should not happen")

  def build([no_children, no_metadata | rest]) do
    {children, rest} = build_children(no_children, rest)
    metadata = Enum.take(rest, no_metadata)

    {%{metadata: metadata, children: children}, Enum.drop(rest, no_metadata)}
  end

  def sum_metadata(tree) do
    Enum.sum(tree.metadata) + (tree.children |> Enum.map(&sum_metadata/1) |> Enum.sum())
  end

  defp build_children(0, data), do: {[], data}

  defp build_children(no_children, data) do
    Enum.reduce(1..no_children, {[], data}, fn _, {children, rest} ->
      {child, rest} = build(rest)
      {[child | children], rest}
    end)
  end
end

File.read!("input.txt")
|> String.split()
|> Enum.map(&String.to_integer/1)
|> Tree.build()
|> elem(0)
|> Tree.sum_metadata()
|> IO.inspect()
