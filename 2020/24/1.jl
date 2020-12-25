include("../util.jl")

using Pipe

function to_coords(direction)
    if direction == "e"
        [1, 0]
    elseif direction == "w"
        [-1, 0]
    elseif direction == "se"
        [1, -1]
    elseif direction == "ne"
        [0, 1]
    elseif direction == "sw"
        [0, -1]
    else
        [-1, 1]
    end
end

function parse_coords(line)
    @pipe eachmatch(r"e|w|ne|se|nw|sw", line) |> map(x -> x.match, _) |> map(to_coords, _) |> sum
end

function apply(flips)
    results = Set()
    for flip in flips
        if flip in results
            delete!(results, flip)
        else
            push!(results, flip)
        end
    end
    results
end

@pipe readlines() |> map(parse_coords, _) |> apply |> length |> println
