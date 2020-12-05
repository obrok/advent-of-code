using Pipe

function parse_line(line)
    @pipe line |> replace(_, r"F|L" => 0) |> replace(_, r"B|R" => 1) |> parse(UInt32, _, base=2)
end

sorted = @pipe readlines() |> map(parse_line, _) |> sort

for i in 1:(length(sorted) - 1)
    if sorted[i] == sorted[i + 1] - 2
        println(sorted[i] + 1)
    end
end
