defmodule Intcode do
  def find(instructions, target) do
    for noun <- 0..99, verb <- 0..99 do
      {noun, verb}
    end
    |> Enum.find(fn {noun, verb} -> 
      result =
        instructions
        |> Map.put(1, noun)
        |> Map.put(2, verb)
        |> run(0)

      result[0] == target
    end)
  end

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
|> Intcode.find(19690720)
|> (fn {x, y} -> 100 * x + y end).()
|> IO.inspect()
