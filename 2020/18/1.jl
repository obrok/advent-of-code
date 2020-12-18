include("../util.jl")

using Pipe

function parse_expression(line, start=1)
    op = :+
    result = []
    i = start

    while i <= length(line)
        char = line[i]

        if char == '+'
            op = :+
        elseif char == '*'
            op = :*
        elseif char == '('
            finish, item = parse_expression(line, i + 1)
            push!(result, op => item)
            i = finish
        elseif char == ')'
            return i => result
        elseif char != ' '
            push!(result, op => parse(Int, char))
        end

        i += 1
    end

    return result
end

function evaluate(expr::Array)
    foldl((acc, (op, item)) -> op == :+ ? acc + evaluate(item) : acc * evaluate(item),
        expr, init=0)
end

function evaluate(x::Int)
    x
end

@pipe readlines() |> map(parse_expression, _) |> map(evaluate, _) |> sum |> println
