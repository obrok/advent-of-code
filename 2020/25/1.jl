include("../util.jl")

using Pipe

function logmod(number, exp, base)
    i = 0
    n = 1
    while n != number
        i += 1
        n = mod(n * exp, base)
    end
    i
end

function powmod(number, exp, base)
    res = 1
    for _ in 1:exp
        res = mod(res * number, base)
    end
    res
end

base = 20201227
a, b = @pipe readlines() |> map(x -> parse(Int, x), _)
powmod(a, logmod(b, 7, base), base) |> println
