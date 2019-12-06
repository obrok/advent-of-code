File.read!("input1.txt")
|> String.split()
|> Enum.map(fn id ->
  id
  |> String.codepoints()
  |> Enum.group_by(& &1)
  |> Enum.map(fn {_, letters} -> length(letters) end)
  |> Enum.into(MapSet.new())
end)
|> Enum.reduce({0, 0}, fn counts, {twos, threes} ->
  cond do
    MapSet.member?(counts, 2) and MapSet.member?(counts, 3) -> {twos + 1, threes + 1}
    MapSet.member?(counts, 2) -> {twos + 1, threes}
    MapSet.member?(counts, 3) -> {twos, threes + 1}
    true -> {twos, threes}
  end
end)
|> (fn {twos, threes} -> twos * threes end).()
|> IO.inspect()
