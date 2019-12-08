defmodule Intcode do
  def run({instructions, pos}, input) do
    {opcode, modes} = extract_modes(instructions[pos])

    case opcode do
      99 ->
        {{instructions, pos}, :halt}

      1 ->
        result = arguments(instructions, pos, 2, modes) |> Enum.sum()
        run({Map.put(instructions, instructions[pos + 3], result), pos + 4}, input)

      2 ->
        [a, b] = arguments(instructions, pos, 2, modes)
        run({Map.put(instructions, instructions[pos + 3], a * b), pos + 4}, input)

      3 ->
        [item | input] = input
        run({Map.put(instructions, instructions[pos + 1], item), pos + 2}, input)

      4 ->
        [result] = arguments(instructions, pos, 1, modes)
        {{instructions, pos + 2}, result}

      5 ->
        [a, b] = arguments(instructions, pos, 2, modes)
        run({instructions, if(a != 0, do: b, else: pos + 3)}, input)

      6 ->
        [a, b] = arguments(instructions, pos, 2, modes)
        run({instructions, if(a == 0, do: b, else: pos + 3)}, input)

      7 ->
        [a, b] = arguments(instructions, pos, 2, modes)
        instructions = Map.put(instructions, instructions[pos + 3], if(a < b, do: 1, else: 0))
        run({instructions, pos + 4}, input)

      8 ->
        [a, b] = arguments(instructions, pos, 2, modes)
        instructions = Map.put(instructions, instructions[pos + 3], if(a == b, do: 1, else: 0))
        run({instructions, pos + 4}, input)

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

defmodule AmplifierSystem do
  def run(program, phases) do
    {amplifiers, value} =
      phases
      |> Enum.with_index()
      |> Enum.reduce({%{}, 0}, fn {phase, index}, {amplifiers, signal} ->
        {state, signal} = Intcode.run({program, 0}, [phase, signal])
        {Map.put(amplifiers, index, state), signal}
      end)

    {amplifiers, value, 0}
    |> Stream.iterate(fn {amplifiers, value, current} ->
      {state, result} = Intcode.run(amplifiers[current], [value])
      {Map.put(amplifiers, current, state), result, rem(current + 1, Enum.count(amplifiers))}
    end)
    |> Stream.map(&elem(&1, 1))
    |> Stream.take_while(&(&1 != :halt))
    |> Enum.reverse()
    |> hd()
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

Permutations.permutations(5..9 |> Enum.to_list())
|> Enum.map(&AmplifierSystem.run(program, &1))
|> Enum.max()
|> IO.inspect()
