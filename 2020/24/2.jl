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

function neighbors(pos)
    @pipe [[1, 0], [-1, 0], [1, -1], [0, 1], [0, -1], [-1, 1]] |> map(x -> pos + x, _) |> Set
end

function run(state, steps)
    for x in 1:steps
        new_state = Set()
        for cell in mapreduce(neighbors, union, state)
            c = @pipe neighbors(cell) |> count(x -> x in state, _)
            if cell in state && c in [1, 2]
                push!(new_state, cell)
            elseif !(cell in state) && c == 2
                push!(new_state, cell)
            end
        end
        state = new_state
    end

    state
end

function parse_coords(line)
    @pipe eachmatch(r"e|w|ne|se|nw|sw", line) |> map(x -> x.match, _) |> map(to_coords, _) |> sum
end

function init(flips)
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

@pipe readlines() |> map(parse_coords, _) |> init |> run(_, 100) |> length |> println
