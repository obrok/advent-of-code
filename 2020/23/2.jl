include("../util.jl")

using Pipe

function play(cups, rounds)
    game_size = length(cups)
    cache = Dict()

    function popcached()
        f = popfirst!(cups)
        if haskey(cache, f)
            for x in reverse(cache[f])
                pushfirst!(cups, x)
            end
            delete!(cache, f)
        end
        f
    end

    for _ in 1:rounds
        top = popcached()
        popped = map(_ -> popcached(), 1:3)
        dest = top
        while dest == top || dest in popped
            dest = mod1(dest - 1, game_size)
        end
        cache[dest] = popped
        push!(cups, top)
    end

    while cups[1] != 1
        push!(cups, popcached())
    end

    popcached()
    popcached() * popcached()
end

start = @pipe readline() |> collect |> map(x -> parse(Int, x), _)
full = [start; 10:1000000]
play(full, 10000000) |> println
