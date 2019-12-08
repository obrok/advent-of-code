defmodule Intcode do
  def run(instructions, pos, input, output \\ []) do
    {opcode, modes} = extract_modes(instructions[pos])

    case opcode do
      99 ->
        {instructions, Enum.reverse(output)}

      1 ->
        result = arguments(instructions, pos, 2, modes) |> Enum.sum()
        run(Map.put(instructions, instructions[pos + 3], result), pos + 4, input, output)

      2 ->
        [a, b] = arguments(instructions, pos, 2, modes)
        run(Map.put(instructions, instructions[pos + 3], a * b), pos + 4, input, output)

      3 ->
        [item | input] = input
        run(Map.put(instructions, instructions[pos + 1], item), pos + 2, input, output)

      4 ->
        [result] = arguments(instructions, pos, 1, modes)
        run(instructions, pos + 2, input, [result | output])

      5 ->
        [a, b] = arguments(instructions, pos, 2, modes)
        run(instructions, if(a != 0, do: b, else: pos + 3), input, output)

      6 ->
        [a, b] = arguments(instructions, pos, 2, modes)
        run(instructions, if(a == 0, do: b, else: pos + 3), input, output)

      7 ->
        [a, b] = arguments(instructions, pos, 2, modes)
        instructions = Map.put(instructions, instructions[pos + 3], if(a < b, do: 1, else: 0))
        run(instructions, pos + 4, input, output)

      8 ->
        [a, b] = arguments(instructions, pos, 2, modes)
        instructions = Map.put(instructions, instructions[pos + 3], if(a == b, do: 1, else: 0))
        run(instructions, pos + 4, input, output)

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

defmodule Permutations do
  def permutations([]), do: [[]]

  def permutations(xs) do
    Enum.flat_map(xs, fn x ->
      permutations(xs -- [x]) |> Enum.map(&[x | &1])
    end)
  end
end

program =
  File.read!("input")
  |> String.trim()
  |> String.split(",")
  |> Enum.map(&String.to_integer/1)
  |> Enum.with_index()
  |> Map.new(fn {n, i} -> {i, n} end)

Permutations.permutations(0..4 |> Enum.to_list())
|> Enum.map(fn phases ->
  Enum.reduce(phases, 0, fn phase, acc ->
    input = [phase, acc]
    {_, [output]} = Intcode.run(program, 0, input)
    output
  end)
end)
|> Enum.max()
|> IO.inspect()
