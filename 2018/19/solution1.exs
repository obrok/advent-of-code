defmodule Register do
  use Bitwise

  def parse(input) do
    [ip | rest] = String.split(input, "\n", trim: true)

    [_, ip] = Regex.run(~r/#ip (\d+)/, ip)

    instructions =
      Enum.map(rest, fn line ->
        [opcode | args] = String.split(line, " ")
        [String.to_existing_atom(opcode) | Enum.map(args, &String.to_integer/1)]
      end)

    %{
      halted?: false,
      regs: [0, 0, 0, 0, 0, 0],
      ip: 0,
      ip_reg: String.to_integer(ip),
      instructions: instructions
    }
  end

  def step(register) do
    if register.ip >= length(register.instructions) do
      %{register | halted?: true}
    else
      register
      |> ip_to_reg()
      |> operate()
      |> reg_to_ip()
    end
  end

  def ip_to_reg(register) do
    put_in(register, [:regs, Access.at(register.ip_reg)], register.ip)
  end

  def operate(register) do
    [op | args] = Enum.at(register.instructions, register.ip)
    update_in(register, [:regs], &operate(&1, op, args))
  end

  def reg_to_ip(register) do
    put_in(register, [:ip], Enum.at(register.regs, register.ip_reg) + 1)
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

File.read!("input.txt")
|> Register.parse()
|> Stream.iterate(&Register.step/1)
|> Stream.drop_while(&(not &1.halted?))
|> Enum.at(0)
|> IO.inspect()
