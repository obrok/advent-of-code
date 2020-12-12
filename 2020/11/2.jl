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
                        if (di != 0 || dj != 0)
                            if look(state, i, j, di, dj)
                                neigh += 1
                            end
                        end
                    end
                end

                if state[i][j] == 'L' && neigh == 0
                    new_state[i][j] = '#'
                elseif state[i][j] == '#' && neigh >= 5
                    new_state[i][j] = 'L'
                end
            end
        end

        state = new_state
    end
end

function look(state, i, j, di, dj)
    i += di
    j += dj
    while i > 0 && j > 0 && i <= length(state) && j <= length(state[1])
        if state[i][j] == '#'
            return true
        elseif state[i][j] == 'L'
            return false
        end

        i += di
        j += dj
    end

    return false
end

end_state = @pipe readlines() |> map(collect, _) |> run

@pipe end_state |> map(x -> count(s -> s == '#', x), _) |> sum |> println
