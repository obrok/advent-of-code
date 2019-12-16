defmodule FFT do
  def phase(numbers) do
    1..length(numbers)
    |> Enum.map(fn index ->
      pattern =
        List.duplicate(0, index) ++ List.duplicate(1, index) ++ List.duplicate(0, index) ++ List.duplicate(-1, index)

      List.duplicate(pattern, div(length(numbers), length(pattern)) + 1)
      |> List.flatten()
      |> Enum.drop(1)
      |> Enum.zip(numbers)
      |> Enum.map(fn {a, b} -> a * b end)
      |> Enum.sum()
    end)
    |> Enum.map(&abs(rem(&1, 10)))
  end
end

File.read!("input")
|> String.trim()
|> String.graphemes()
|> Enum.map(&String.to_integer/1)
|> Stream.iterate(&FFT.phase/1)
|> Enum.at(100)
|> Enum.take(8)
|> Enum.join("")
|> IO.inspect()
