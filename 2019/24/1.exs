defmodule Life do
  def parse(input) do
    for {line, y} <- input |> String.split("\n") |> Enum.with_index(),
        {char, x} <- line |> String.graphemes() |> Enum.with_index(),
        into: %{} do
      {{x, y}, char}
    end
  end

  def step(board) do
    for x <- 0..4, y <- 0..4, into: %{} do
      {{x, y}, next_gen(board, {x, y})}
    end
  end

  def next_gen(board, pos) do
    neighbors = pos |> neighbors() |> Enum.count(&(board[&1] == "#"))

    cond do
      board[pos] == "#" && neighbors != 1 -> "."
      board[pos] == "." && neighbors in [1, 2] -> "#"
      true -> board[pos]
    end
  end

  def neighbors({x, y}), do: [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]

  def biodiversity(board) do
    for y <- 0..4, x <- 0..4 do
      {x, y}
    end
    |> Enum.with_index()
    |> Enum.filter(fn {pos, _} -> board[pos] == "#" end)
    |> Enum.map(fn {_, i} -> :math.pow(2, i) |> round() end)
    |> Enum.sum()
  end

  def inspect(board) do
    for y <- 0..4 do
      for x <- 0..4 do
        IO.write(board[{x, y}])
      end

      IO.puts("")
    end

    IO.puts("")

    board
  end
end

File.read!("input")
|> Life.parse()
|> Stream.iterate(&Life.step/1)
|> Stream.transform(
  MapSet.new(),
  fn
    _, :halt ->
      {:halt, nil}

    state, seen ->
      if MapSet.member?(seen, state) do
        {[state], :halt}
      else
        {[state], MapSet.put(seen, state)}
      end
  end
)
|> Enum.at(-1)
|> Life.inspect()
|> Life.biodiversity()
|> IO.inspect()
