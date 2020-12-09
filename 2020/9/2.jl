include("../util.jl")

using Pipe

function validate(data)
    window = []

    for i in 1:25
        push!(window, data[i])
    end

    for i in 26:length(data)
        if validate_one(window, data[i])
            popfirst!(window)
            push!(window, data[i])
        else
            return data[i]
        end
    end
end

function validate_one(window, next)
    for x in window
        for y in window
            if x + y == next
                return true
            end
        end
    end

    return false
end

function find_weakness(data, invalid)
    for i in 1:length(data)
        for j in 1:length(data)
            if sum(data[i:j]) == invalid
                return data[i:j]
            end
        end
    end
end

data = @pipe readlines() |> map(x -> parse(UInt64, x), _)
invalid = validate(data)
weakness = find_weakness(data, invalid)
println(maximum(weakness) + minimum(weakness))
