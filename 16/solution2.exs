defmodule Register do
  use Bitwise

  def parse_program(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line |> String.split(" ") |> Enum.map(&String.to_integer/1)
    end)
  end

  def run(mapping, program, regs \\ [0, 0, 0, 0])
  def run(_mapping, [], regs), do: regs

  def run(mapping, [[op | args] | rest], regs) do
    run(mapping, rest, operate(regs, mapping[op], args))
  end

  def parse_samples(input) do
    Regex.scan(~r/Before:.*?\[(.*?)\].*?(\d* \d* \d* \d*).*?After:.*?\[(.*?)\]/s, input)
    |> Enum.map(fn [_, before, opcode, afterwards] ->
      %{
        before: before |> String.split(", ") |> Enum.map(&String.to_integer/1),
        opcode: opcode |> String.split(" ") |> Enum.map(&String.to_integer/1),
        afterwards: afterwards |> String.split(", ") |> Enum.map(&String.to_integer/1)
      }
    end)
  end

  def operate(regs, op, [a, b, c]) do
    case op do
      :addr -> store(regs, c, get(regs, a) + get(regs, b))
      :addi -> store(regs, c, get(regs, a) + b)
      :mulr -> store(regs, c, get(regs, a) * get(regs, b))
      :muli -> store(regs, c, get(regs, a) * b)
      :banr -> store(regs, c, get(regs, a) &&& get(regs, b))
      :bani -> store(regs, c, get(regs, a) &&& b)
      :borr -> store(regs, c, get(regs, a) ||| get(regs, b))
      :bori -> store(regs, c, get(regs, a) ||| b)
      :setr -> store(regs, c, get(regs, a))
      :seti -> store(regs, c, a)
      :gtir -> store(regs, c, if(a > get(regs, b), do: 1, else: 0))
      :gtri -> store(regs, c, if(get(regs, a) > b, do: 1, else: 0))
      :gtrr -> store(regs, c, if(get(regs, a) > get(regs, b), do: 1, else: 0))
      :eqir -> store(regs, c, if(a == get(regs, b), do: 1, else: 0))
      :eqri -> store(regs, c, if(get(regs, a) == b, do: 1, else: 0))
      :eqrr -> store(regs, c, if(get(regs, a) == get(regs, b), do: 1, else: 0))
    end
  end

  def guess(impossible, guesses \\ %{}) do
    impossible
    |> Enum.map(fn {opcode, impossible} ->
      possible =
        MapSet.new(0..15)
        |> MapSet.difference(impossible)
        |> MapSet.difference(MapSet.new(Map.values(guesses)))
        |> Enum.into([])

      {opcode, possible}
    end)
    |> Enum.find(fn {_, possible} -> length(possible) == 1 end)
    |> case do
      {opcode, [possible]} -> guess(impossible, Map.put(guesses, opcode, possible))
      _ -> guesses |> Enum.map(fn {k, v} -> {v, k} end) |> Enum.into(%{})
    end
  end

  def opcodes() do
    ~w(addr addi mulr muli banr bani borr bori setr seti gtir gtri gtrr eqir eqri eqrr)a
  end

  defp store(regs, i, v), do: List.replace_at(regs, i, v)

  defp get(regs, i), do: Enum.at(regs, i)
end

File.read!("input_samples.txt")
|> Register.parse_samples()
|> Enum.flat_map(fn sample = %{opcode: [number | args]} ->
  Register.opcodes()
  |> Enum.reject(&(Register.operate(sample.before, &1, args) == sample.afterwards))
  |> Enum.map(&{&1, number})
end)
|> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
|> Enum.map(fn {opcode, impossible} -> {opcode, MapSet.new(impossible)} end)
|> Enum.into(%{})
|> Register.guess()
|> Register.run(Register.parse_program(File.read!("input.txt")))
|> IO.inspect()
