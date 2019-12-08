defmodule Layer do
  def decode([[] | _]), do: []

  def decode(layers) do
    [
      layers |> Enum.map(&hd/1) |> Enum.find(&(&1 != "2"))
      | decode(layers |> Enum.map(&Enum.drop(&1, 1)))
    ]
  end
end

width = 25
height = 6

File.read!("input")
|> String.trim()
|> String.graphemes()
|> Enum.chunk_every(width * height)
|> Layer.decode()
|> Enum.map(fn
  "1" -> "#"
  _ -> "."
end)
|> Enum.chunk_every(width)
|> Enum.map(&Enum.join(&1, " "))
|> Enum.join("\n")
|> IO.puts()
