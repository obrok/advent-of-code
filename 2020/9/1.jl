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

@pipe readlines() |> map(x -> parse(UInt64, x), _) |> validate |> println
