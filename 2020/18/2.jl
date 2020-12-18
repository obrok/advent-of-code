include("../util.jl")

using Pipe

function parse_expression(line, start=1)
    val1, start = parse_add(line, start)
    if start <= length(line) && line[start] == '*'
        val2, start = parse_expression(line, start + 1)
        ((:*, val1, val2), start)
    else
        (val1, start)
    end
end

function parse_add(line, start)
    val1, start = parse_paren(line, start)
    if start <= length(line) && line[start] == '+'
        val2, start = parse_add(line, start + 1)
        ((:+, val1, val2), start)
    else
        (val1, start)
    end
end

function parse_paren(line, start)
    if line[start] == '('
        val, start = parse_expression(line, start + 1)
        (val, start + 1)
    else
        (parse(Int, line[start]), start + 1)
    end
end

function evaluate(x::Int)
    x
end

function evaluate((op, a, b))
    if op == :+
        evaluate(a) + evaluate(b)
    else
        evaluate(a) * evaluate(b)
    end
end

@pipe readlines() |> map(x -> replace(x, " " => ""), _) |> map(parse_expression, _) |>
    map(x -> x[1], _) |> map(evaluate, _) |> sum |> println
