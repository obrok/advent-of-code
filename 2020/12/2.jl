include("../util.jl")

using Pipe

function parse_line(line)
    m = match(r"^(.)(\d+)$", line)
    m[1] => parse(Int32, m[2])
end

function move(instructions)
    x = 0
    y = 0
    tx = 10
    ty = 1

    for ins in instructions
        if ins[1] == "E"
            tx += ins[2]
        elseif ins[1] == "W"
            tx -= ins[2]
        elseif ins[1] == "N"
            ty += ins[2]
        elseif ins[1] == "S"
            ty -= ins[2]
        elseif ins[1] == "F"
            x += tx * ins[2]
            y += ty * ins[2]
        elseif ins[1] == "R"
            for _ in 1:(ins[2] ÷ 90)
                tx = -tx
                tx, ty = ty, tx
            end
        elseif ins[1] == "L"
            for _ in 1:(360 - ins[2] ÷ 90)
                tx = -tx
                tx, ty = ty, tx
            end
        end
    end

    abs(x) + abs(y)
end

@pipe readlines() |> map(parse_line, _) |> move |> println
