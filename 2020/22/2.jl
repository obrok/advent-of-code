include("../util.jl")

using Pipe

function play(deck1, deck2)
    visited = Set()

    while !isempty(deck1) && !isempty(deck2)
        if (deck1, deck2) in visited
            return (deck1, 1)
        end
        push!(visited, (copy(deck1), copy(deck2)))

        c1 = popfirst!(deck1)
        c2 = popfirst!(deck2)
        if (c1 > length(deck1) || c2 > length(deck2))
            if c1 > c2
                push!(deck1, c1)
                push!(deck1, c2)
            else
                push!(deck2, c2)
                push!(deck2, c1)
            end
        else
            _, result = play(deck1[1:c1] |> collect, deck2[1:c2] |> collect)
            if result == 1
                push!(deck1, c1)
                push!(deck1, c2)
            else
                push!(deck2, c2)
                push!(deck2, c1)
            end
        end
    end

    isempty(deck1) ? (deck2, 2) : (deck1, 1)
end

function score(deck)
    @pipe reverse(deck) |> enumerate |> map(prod, _) |> sum
end

deck1, deck2 = @pipe readlines() |> chunk_on(_, "") |> map(deck -> map(x -> parse(Int, x), deck[2:lastindex(deck)]), _)
play(deck1, deck2) |> first |> score |> println
