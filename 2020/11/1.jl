include("../util.jl")

using Pipe

function run(state)
    visited = Set()

    while true
        if state in visited
            return state
        end

        push!(visited, state)
        new_state = deepcopy(state)

        for i in 1:length(state)
            for j in 1:length(state[1])
                neigh = 0

                for di in -1:1
                    for dj in -1:1
                        if (di != 0 || dj != 0) && i + di > 0 && j + dj > 0 &&
                            i + di <= length(state) && j + dj <= length(state[1]) &&
                            state[i + di][j + dj] == '#'
                            neigh += 1
                        end
                    end
                end

                if state[i][j] == 'L' && neigh == 0
                    new_state[i][j] = '#'
                elseif state[i][j] == '#' && neigh >= 4
                    new_state[i][j] = 'L'
                end
            end
        end

        state = new_state
    end
end

end_state = @pipe readlines() |> map(collect, _) |> run

@pipe end_state |> map(x -> count(s -> s == '#', x), _) |> sum |> println
