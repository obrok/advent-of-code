defmodule Tree do
  def build([]), do: raise("Should not happen")

  def build([no_children, no_metadata | rest]) do
    {children, rest} = build_children(no_children, rest)
    metadata = Enum.take(rest, no_metadata)

    {%{metadata: metadata, children: Enum.reverse(children)}, Enum.drop(rest, no_metadata)}
  end

  def value(%{metadata: metadata, children: []}), do: Enum.sum(metadata)

  def value(%{metadata: metadata, children: children}) do
    metadata |> Enum.map(&metadata_value(&1, children)) |> Enum.sum()
  end

  defp metadata_value(0, _children), do: 0

  defp metadata_value(index, children) do
    case Enum.at(children, index - 1) do
      nil -> 0
      child -> value(child)
    end
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
|> Tree.value()
|> IO.inspect()
