input = 240920..789857

input
|> Stream.map(&to_string/1)
|> Stream.map(&String.graphemes/1)
|> Stream.map(& &1 |> Enum.chunk_every(2, 1) |> Enum.take(5))
|> Stream.filter(fn x -> Enum.all?(x, fn [a, b] -> b >= a end) end)
|> Stream.filter(fn x -> Enum.any?(x, fn [a, b] -> b == a end) end)
|> Enum.count()
|> IO.inspect()
