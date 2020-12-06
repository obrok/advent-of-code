using Pipe

function groups()
    result = []
    item = nothing

    for line in readlines()
        if line == ""
            push!(result, item)
            item = nothing
        else
            matches = @pipe line |> eachmatch(r".", _) |> map(x -> x.match, _)
            if item == nothing
                item = Set(matches)
            else
                intersect!(item, matches)
            end
        end
    end

    push!(result, item)
    result
end

@pipe groups() |> sum(x -> length(x), _) |> println
