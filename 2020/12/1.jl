include("../util.jl")

using Pipe

function parse_line(line)
    m = match(r"^(.)(\d+)$", line)
    m[1] => parse(Int32, m[2])
end

function move(instructions)
    x = 0
    y = 0
    d = 1
    ds = [(1, 0), (0, -1), (-1, 0), (0, 1)]

    for ins in instructions
        if ins[1] == "E"
            x += ins[2]
        elseif ins[1] == "W"
            x -= ins[2]
        elseif ins[1] == "N"
            y += ins[2]
        elseif ins[1] == "S"
            y -= ins[2]
        elseif ins[1] == "F"
            x += ds[d][1] * ins[2]
            y += ds[d][2] * ins[2]
        elseif ins[1] == "R"
            d = (d - 1 + ins[2] ÷ 90) % 4 + 1
        elseif ins[1] == "L"
            d = (d - 1 + 360 - ins[2] ÷ 90) % 4 + 1
        end
    end

    abs(x) + abs(y)
end

@pipe readlines() |> map(parse_line, _) |> move |> println
