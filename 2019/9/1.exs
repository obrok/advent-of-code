defmodule Intcode do
  def run({instructions, pos, base}, input) do
    {opcode, modes} = extract_modes(instructions[pos])

    # IO.inspect(base)
    # pos..(pos + 3) |> Enum.map(&instructions[&1]) |> IO.inspect()

    case opcode do
      99 ->
        {{instructions, pos, base}, :halt}

      1 ->
        result = arguments(instructions, pos, 2, modes, base) |> Enum.sum()
        run({Map.put(instructions, target(instructions[pos + 3], 3, modes, base), result), pos + 4, base}, input)

      2 ->
        [a, b] = arguments(instructions, pos, 2, modes, base)
        run({Map.put(instructions, target(instructions[pos + 3], 3, modes, base), a * b), pos + 4, base}, input)

      3 ->
        [item | input] = input
        run({Map.put(instructions, target(instructions[pos + 1], 1, modes, base), item), pos + 2, base}, input)

      4 ->
        [result] = arguments(instructions, pos, 1, modes, base)
        {{instructions, pos + 2, base}, result}

      5 ->
        [a, b] = arguments(instructions, pos, 2, modes, base)
        run({instructions, if(a != 0, do: b, else: pos + 3), base}, input)

      6 ->
        [a, b] = arguments(instructions, pos, 2, modes, base)
        run({instructions, if(a == 0, do: b, else: pos + 3), base}, input)

      7 ->
        [a, b] = arguments(instructions, pos, 2, modes, base)
        instructions = Map.put(instructions, target(instructions[pos + 3], 3, modes, base), if(a < b, do: 1, else: 0))
        run({instructions, pos + 4, base}, input)

      8 ->
        [a, b] = arguments(instructions, pos, 2, modes, base)
        instructions = Map.put(instructions, target(instructions[pos + 3], 3, modes, base), if(a == b, do: 1, else: 0))
        run({instructions, pos + 4, base}, input)

      9 ->
        [a] = arguments(instructions, pos, 1, modes, base)
        run({instructions, pos + 2, base + a}, input)

      _ ->
        raise "Unknown opcode #{opcode}"
    end
  end

  def arguments(instructions, pos, count, modes, base) do
    (pos + 1)..(pos + count)
    |> Enum.map(&instructions[&1])
    |> Enum.zip(modes)
    |> Enum.map(&argument(instructions, &1, base))
  end

  def argument(_, {value, 1}, _), do: value
  def argument(instructions, {pos, 2}, base), do: Map.get(instructions, pos + base, 0)
  def argument(instructions, {pos, 0}, _), do: Map.get(instructions, pos, 0)

  def target(value, position, modes, base) do
    case Enum.at(modes, position - 1) do
      0 -> value
      2 -> base + value
      mode -> raise "Invalid target mode #{mode}"
    end
  end

  def extract_modes(opcode) do
    {
      rem(opcode, 100),
      div(opcode, 100)
      |> Stream.iterate(&div(&1, 10))
      |> Stream.map(&rem(&1, 10))
    }
  end
end

program =
  File.read!("input")
  |> String.trim()
  |> String.split(",")
  |> Enum.map(&String.to_integer/1)
  |> Enum.with_index()
  |> Map.new(fn {n, i} -> {i, n} end)

{{program, 0, 0}, nil}
|> Stream.iterate(fn {state, _output} -> Intcode.run(state, [2]) end)
|> Stream.map(&elem(&1, 1))
|> Enum.take_while(&(&1 != :halt))
|> Enum.join("\n")
|> IO.puts()
