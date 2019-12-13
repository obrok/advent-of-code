defmodule Intcode do
  def parse(string) do
    string
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Map.new(fn {n, i} -> {i, n} end)
  end

  def run({instructions, pos, base}, input) do
    {opcode, modes} = extract_modes(instructions[pos])

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
        case input do
          nil ->
            {{instructions, pos, base}, :input}

          input ->
            item = input
            run({Map.put(instructions, target(instructions[pos + 1], 1, modes, base), item), pos + 2, base}, nil)
        end

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

defmodule Game do
  def parse(data) do
    data
    |> Enum.chunk_every(3)
    |> Map.new(fn [x, y, type] -> {{x, y}, type} end)
  end

  def best_move(game) do
    {{ball, _}, _} = game |> Enum.find(&match?({{x, _}, 4}, &1))
    {{paddle, _}, _} = game |> Enum.find(&match?({{x, _}, 3}, &1))

    cond do
      ball > paddle -> 1
      ball < paddle -> -1
      true -> 0
    end
  end

  def print(game) do
    max_x = game |> Map.keys() |> Enum.map(&elem(&1, 0)) |> Enum.max()
    max_y = game |> Map.keys() |> Enum.map(&elem(&1, 1)) |> Enum.max()

    for y <- 0..max_y do
      for x <- 0..max_x do
        case game[{x, y}] do
          1 -> "#"
          2 -> "@"
          3 -> "_"
          4 -> "o"
          _ -> " "
        end
      end
      |> Enum.join("")
      |> IO.puts()
    end

    IO.puts("\nSCORE: #{game[{-1, 0}]}")
  end
end

program = File.read!("input") |> Intcode.parse() |> Map.put(0, 2)

{{program, 0, 0}, %{}, [], nil}
|> Stream.iterate(fn {state, screen, outputs, input} ->
  case Intcode.run(state, input) do
    {_, :halt} ->
      screen = Map.merge(screen, outputs |> Enum.reverse() |> Game.parse())
      Game.print(screen)
      :halt

    {state, :input} ->
      screen = Map.merge(screen, outputs |> Enum.reverse() |> Game.parse())
      Game.print(screen)
      input = Game.best_move(screen)
      {state, screen, [], input}

    {state, output} ->
      {state, screen, [output | outputs], nil}
  end
end)
|> Enum.take_while(&(&1 != :halt))
