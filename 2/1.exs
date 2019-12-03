defmodule Intcode do
  def run(instructions, pos) do
    case instructions[pos] do
      99 -> instructions
      1 ->
        result = instructions[instructions[pos + 1]] + instructions[instructions[pos + 2]]
        run(Map.put(instructions, instructions[pos + 3], result), pos + 4)
      2 ->
        result = instructions[instructions[pos + 1]] * instructions[instructions[pos + 2]]
        run(Map.put(instructions, instructions[pos + 3], result), pos + 4)
      _ -> raise "Unknown opcode"
    end
  end
end

File.read!("input")
|> String.trim()
|> String.split(",")
|> Enum.map(&String.to_integer/1)
|> Enum.with_index()
|> Map.new(fn {n, i} -> {i, n} end)
|> Map.put(1, 12)
|> Map.put(2, 2)
|> Intcode.run(0)
|> (fn x -> x[0] end).()
|> IO.inspect()
