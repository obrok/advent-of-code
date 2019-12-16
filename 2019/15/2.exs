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

defmodule Repair do
  def find_oxygen_tank(queue, visited) do
    {{:value, {intcode, location, distance}}, queue} =
      case :queue.out(queue) do
        {{:value, {{intcode, :found}, location, distance}}, queue} ->
          explore(:queue.from_list([{intcode, location, 0}]), MapSet.new())

        other ->
          other
      end

    visited = MapSet.put(visited, location)

    new_queue =
      Enum.reduce(1..4, queue, fn direction, queue ->
        new_location = move(location, direction)

        if !MapSet.member?(visited, new_location) do
          case Intcode.run(intcode, direction) do
            {new_intcode, 0} -> queue
            {new_intcode, 1} -> :queue.in({new_intcode, new_location, distance + 1}, queue)
            {new_intcode, 2} -> :queue.in({{new_intcode, :found}, new_location, distance + 1}, queue)
          end
        else
          queue
        end
      end)

    find_oxygen_tank(new_queue, visited)
  end

  def explore(queue, visited) do
    {{:value, {intcode, location, distance}}, queue} = :queue.out(queue)
    IO.inspect(distance)

    visited = MapSet.put(visited, location)

    new_queue =
      Enum.reduce(1..4, queue, fn direction, queue ->
        new_location = move(location, direction)

        if !MapSet.member?(visited, new_location) do
          case Intcode.run(intcode, direction) do
            {new_intcode, 0} -> queue
            {new_intcode, 1} -> :queue.in({new_intcode, new_location, distance + 1}, queue)
            {new_intcode, 2} -> :queue.in({new_intcode, new_location, distance + 1}, queue)
          end
        else
          queue
        end
      end)

    explore(new_queue, visited)
  end

  def move({x, y}, 1), do: {x, y + 1}
  def move({x, y}, 2), do: {x, y - 1}
  def move({x, y}, 3), do: {x + 1, y}
  def move({x, y}, 4), do: {x - 1, y}
end

program = File.read!("input") |> Intcode.parse()

Repair.find_oxygen_tank(:queue.from_list([{{program, 0, 0}, {0, 0}, 0}]), MapSet.new())
|> IO.inspect()
