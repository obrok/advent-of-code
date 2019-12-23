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
        {{Map.put(instructions, target(instructions[pos + 3], 3, modes, base), result), pos + 4, base}, :cont}

      2 ->
        [a, b] = arguments(instructions, pos, 2, modes, base)
        {{Map.put(instructions, target(instructions[pos + 3], 3, modes, base), a * b), pos + 4, base}, :cont}

      3 ->
        {{Map.put(instructions, target(instructions[pos + 1], 1, modes, base), input), pos + 2, base}, :input}

      4 ->
        [result] = arguments(instructions, pos, 1, modes, base)
        {{instructions, pos + 2, base}, {:output, result}}

      5 ->
        [a, b] = arguments(instructions, pos, 2, modes, base)
        {{instructions, if(a != 0, do: b, else: pos + 3), base}, :cont}

      6 ->
        [a, b] = arguments(instructions, pos, 2, modes, base)
        {{instructions, if(a == 0, do: b, else: pos + 3), base}, :cont}

      7 ->
        [a, b] = arguments(instructions, pos, 2, modes, base)
        instructions = Map.put(instructions, target(instructions[pos + 3], 3, modes, base), if(a < b, do: 1, else: 0))
        {{instructions, pos + 4, base}, :cont}

      8 ->
        [a, b] = arguments(instructions, pos, 2, modes, base)
        instructions = Map.put(instructions, target(instructions[pos + 3], 3, modes, base), if(a == b, do: 1, else: 0))
        {{instructions, pos + 4, base}, :cont}

      9 ->
        [a] = arguments(instructions, pos, 1, modes, base)
        {{instructions, pos + 2, base + a}, :cont}

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

defmodule NIC do
  def new(program, address) do
    %{
      address: address,
      machine: {program, 0, 0},
      outputs: [],
      inputs: [address]
    }
  end

  def step(nic) do
    input =
      case nic.inputs do
        [next | _] -> next
        [] -> -1
      end

    case Intcode.run(nic.machine, input) do
      {machine, :cont} -> %{nic | machine: machine}
      {machine, :input} -> %{nic | machine: machine, inputs: consume(nic.inputs)}
      {machine, {:output, item}} -> %{nic | machine: machine, outputs: [item | nic.outputs]}
    end
  end

  def extract_sent_packets(nic = %{outputs: [y, x, a]}), do: {%{nic | outputs: []}, [{a, x, y}]}
  def extract_sent_packets(nic), do: {nic, []}

  def consume([]), do: []
  def consume([_ | rest]), do: rest
end

defmodule Network do
  def new(program) do
    for address <- 0..49 do
      NIC.new(program, address)
    end
  end

  def run(network, sent \\ 0, i \\ 0) do
    network_with_packets =
      for nic <- network do
        nic |> NIC.step() |> NIC.extract_sent_packets()
      end

    packets =
      network_with_packets
      |> Enum.flat_map(&elem(&1, 1))
      |> Enum.group_by(&elem(&1, 0), fn {_, x, y} -> [x, y] end)

    sent = sent + Enum.count(packets)
    i = i + 1

    if Enum.count(packets) > 0 do
      IO.inspect(i)
      IO.inspect(packets)
    end

    for {nic, _} <- network_with_packets do
      case packets[nic.address] do
        nil -> nic
        packets -> %{nic | inputs: nic.inputs ++ List.flatten(packets)}
      end
    end
    |> run(sent, i)
  end
end

File.read!("input")
|> Intcode.parse()
|> Network.new()
|> Network.run()
|> IO.inspect()
