defmodule Register do
  use Bitwise

  def parse_samples(input) do
    Regex.scan(~r/Before:.*?\[(.*?)\].*?(\d \d \d \d).*?After:.*?\[(.*?)\]/s, input)
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

  defp store(regs, i, v), do: List.replace_at(regs, i, v)

  defp get(regs, i), do: Enum.at(regs, i)
end

opcodes = [
  :addr,
  :addi,
  :mulr,
  :muli,
  :banr,
  :bani,
  :borr,
  :bori,
  :setr,
  :seti,
  :gtir,
  :gtri,
  :gtrr,
  :eqir,
  :eqri,
  :eqrr
]

File.read!("input_samples.txt")
|> Register.parse_samples()
|> Enum.count(fn %{before: before, afterwards: afterwards, opcode: [_ | args]} ->
  Enum.count(opcodes, &(Register.operate(before, &1, args) == afterwards)) >= 3
end)
|> IO.inspect()
