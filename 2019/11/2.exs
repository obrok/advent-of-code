defmodule Intcode do
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

defmodule Robot do
  def run(program_state, {hull, direction, position}) do
    current_panel = Map.get(hull, position, 0)

    case Intcode.run(program_state, [current_panel]) do
      {_, :halt} ->
        :halt

      {program_state, color} ->
        {program_state, turn} = Intcode.run(program_state, [])
        hull = Map.put(hull, position, color)
        {direction, position} = make_turn(direction, position, turn)
        {program_state, {hull, direction, position}}
    end
  end

  def make_turn(direction, position, turn) do
    directions = [:up, :right, :down, :left]
    turn = if(turn == 0, do: -1, else: 1)
    dir_index = directions |> Enum.find_index(fn x -> x == direction end)
    dir_index = rem(dir_index + turn, 4)
    direction = Enum.at(directions, dir_index)
    {direction, move(position, direction)}
  end

  def move({x, y}, :up), do: {x, y + 1}
  def move({x, y}, :down), do: {x, y - 1}
  def move({x, y}, :left), do: {x - 1, y}
  def move({x, y}, :right), do: {x + 1, y}
end

program =
  File.read!("input")
  |> String.trim()
  |> String.split(",")
  |> Enum.map(&String.to_integer/1)
  |> Enum.with_index()
  |> Map.new(fn {n, i} -> {i, n} end)

{{program, 0, 0}, {%{{0, 0} => 1}, :up, {0, 0}}}
|> Stream.iterate(fn {program_state, robot_state} -> Robot.run(program_state, robot_state) end)
|> Stream.take_while(&(&1 != :halt))
|> Enum.at(-1)
|> (fn {_, {hull, _, _}} ->
      {min_x, max_x} = hull |> Map.keys() |> Enum.map(&elem(&1, 0)) |> Enum.min_max()
      {min_y, max_y} = hull |> Map.keys() |> Enum.map(&elem(&1, 1)) |> Enum.min_max()

      for y <- min_y..max_y do
        for x <- min_x..max_x do
          if(hull[{x, y}] == 1, do: "#", else: " ")
        end
        |> Enum.join(" ")
      end
      |> Enum.reverse()
      |> Enum.join("\n")
    end).()
|> IO.puts()
