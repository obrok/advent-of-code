using Pipe

function groups()
    result = []
    item = Set{AbstractString}()

    for line in readlines()
        if line == ""
            push!(result, item)
            item = Set()
        else
            matches = @pipe line |> eachmatch(r".", _) |> map(x -> x.match, _)
            union!(item, matches)
        end
    end

    push!(result, item)
    result
end

@pipe groups() |> sum(x -> length(x), _) |> println
