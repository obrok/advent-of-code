defmodule Intcode do
  def run(instructions, pos, input) do
    {opcode, modes} = extract_modes(instructions[pos])

    case opcode do
      99 ->
        instructions

      1 ->
        result = arguments(instructions, pos, 2, modes) |> Enum.sum()
        run(Map.put(instructions, instructions[pos + 3], result), pos + 4, input)

      2 ->
        [a, b] = arguments(instructions, pos, 2, modes)
        run(Map.put(instructions, instructions[pos + 3], a * b), pos + 4, input)

      3 ->
        [item | input] = input
        run(Map.put(instructions, instructions[pos + 1], item), pos + 2, input)

      4 ->
        [result] = arguments(instructions, pos, 1, modes)
        IO.puts(result)
        run(instructions, pos + 2, input)

      _ ->
        raise "Unknown opcode #{opcode}"
    end
  end

  def arguments(instructions, pos, count, modes) do
    (pos + 1)..(pos + count)
    |> Enum.map(&instructions[&1])
    |> Enum.zip(modes)
    |> Enum.map(&argument(instructions, &1))
  end

  def argument(_, {value, 1}), do: value
  def argument(instructions, {pos, 0}), do: instructions[pos]

  def extract_modes(opcode) do
    {
      rem(opcode, 100),
      div(opcode, 100)
      |> Stream.iterate(&div(&1, 10))
      |> Stream.map(&rem(&1, 10))
    }
  end
end

File.read!("input")
|> String.trim()
|> String.split(",")
|> Enum.map(&String.to_integer/1)
|> Enum.with_index()
|> Map.new(fn {n, i} -> {i, n} end)
|> Intcode.run(0, [1])
