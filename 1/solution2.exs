File.read!("input2.txt")
|> String.split()
|> Enum.map(&String.to_integer/1)
|> Stream.cycle()
|> Stream.transform(0, fn a, b -> {[a + b], a + b} end)
|> Stream.transform(MapSet.new(), fn
  _, :halt ->
    {:halt, nil}

  v, visited ->
    if MapSet.member?(visited, v) do
      {[v], :halt}
    else
      {[v], MapSet.put(visited, v)}
    end
end)
|> Enum.into([])
|> :lists.last()
|> IO.inspect()
