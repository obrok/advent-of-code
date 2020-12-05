using Pipe

function parse_line(line)
    @pipe line |> replace(_, r"F|L" => 0) |> replace(_, r"B|R" => 1) |> parse(UInt32, _, base=2)
end

@pipe readlines() |> map(parse_line, _) |> maximum |> println
