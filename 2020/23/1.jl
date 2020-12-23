include("../util.jl")

using Pipe

function play(cups, rounds)
    for _ in 1:rounds
        popped = map(_ -> popat!(cups, 2), 1:3)
        dest = first(cups)
        while dest == first(cups) || dest in popped
            dest = mod1(dest - 1, 9)
        end
        target = findfirst(x -> x == dest, cups)
        @pipe popped |> reverse |> map(x -> insert!(cups, target + 1, x), _)
        push!(cups, popfirst!(cups))
    end

    while first(cups) != 1
        push!(cups, popfirst!(cups))
    end

    join(cups[2:9], "")
end

@pipe readline() |> collect |> map(x -> parse(Int, x), _) |> play(_, 100) |> println
