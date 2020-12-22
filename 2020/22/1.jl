include("../util.jl")

using Pipe

function play(deck1, deck2)
    while !isempty(deck1) && !isempty(deck2)
        if deck1[1] < deck2[1]
            deck1, deck2 = (deck2, deck1)
        end
        push!(deck1, popfirst!(deck1))
        push!(deck1, popfirst!(deck2))
    end

    deck1
end

function score(deck)
    @pipe reverse(deck) |> enumerate |> map(prod, _) |> sum
end

deck1, deck2 = @pipe readlines() |> chunk_on(_, "") |> map(deck -> map(x -> parse(Int, x), deck[2:lastindex(deck)]), _)
play(deck1, deck2) |> score |> println
