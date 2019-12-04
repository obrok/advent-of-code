input = 240920..789857

input
|> Stream.map(&to_string/1)
|> Stream.map(&String.graphemes/1)
|> Stream.map(fn x -> Enum.chunk_by(x, & &1) end)
|> Stream.filter(fn x -> Enum.sort(x) == x end)
|> Stream.filter(fn x -> Enum.any?(x, &length(&1) == 2) end)
|> Enum.count()
|> IO.inspect()
