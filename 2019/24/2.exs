defmodule Life do
  def parse(input) do
    for {line, y} <- input |> String.split("\n") |> Enum.with_index(),
        {char, x} <- line |> String.graphemes() |> Enum.with_index(),
        x != 2 || y != 2,
        into: %{} do
      {{x, y, 0}, char}
    end
  end

  def step(board) do
    for pos <- board |> Map.keys() |> Stream.flat_map(&neighbors/1) |> Enum.into(MapSet.new()), into: %{} do
      {pos, next_gen(board, pos)}
    end
  end

  def next_gen(board, pos) do
    neighbors = pos |> neighbors() |> Enum.count(&(board[&1] == "#"))

    cond do
      board[pos] == "#" && neighbors != 1 -> "."
      board[pos] != "#" && neighbors in [1, 2] -> "#"
      true -> board[pos] || "."
    end
  end

  def neighbors({1, 2, l}), do: [{0, 2, l}, {1, 1, l}, {1, 3, l} | Enum.map(0..4, &{0, &1, l + 1})]
  def neighbors({3, 2, l}), do: [{4, 2, l}, {3, 1, l}, {3, 3, l} | Enum.map(0..4, &{4, &1, l + 1})]
  def neighbors({2, 1, l}), do: [{2, 0, l}, {3, 1, l}, {1, 1, l} | Enum.map(0..4, &{&1, 0, l + 1})]
  def neighbors({2, 3, l}), do: [{2, 4, l}, {3, 3, l}, {1, 3, l} | Enum.map(0..4, &{&1, 4, l + 1})]

  def neighbors({x, y, l}) do
    [{x + 1, y, l}, {x - 1, y, l}, {x, y + 1, l}, {x, y - 1, l}]
    |> Enum.map(&adjust_level/1)
  end

  def adjust_level({-1, _, l}), do: {1, 2, l - 1}
  def adjust_level({5, _, l}), do: {3, 2, l - 1}
  def adjust_level({_, -1, l}), do: {2, 1, l - 1}
  def adjust_level({_, 5, l}), do: {2, 3, l - 1}
  def adjust_level(other), do: other

  def inspect(board, layer) do
    for y <- 0..4 do
      for x <- 0..4 do
        IO.write(board[{x, y, layer}] || "?")
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
|> Enum.at(200)
|> Enum.count(fn {_, v} -> v == "#" end)
|> IO.inspect()
