include("../util.jl")

using Pipe

function graph()
    function graph_item(line)
        container = match(r"^(.*?) bags", line)[1]
        contents = @pipe line |> eachmatch(r"(\d) (.*?) bags?", _) |> map(function (x)
            x[2] => parse(UInt32, x[1])
        end, _)

        container => Dict(contents)
    end

    @pipe readlines() |> map(graph_item, _) |> Dict
end

function parent(graph)
    result = Dict()

    for x in graph
        container, contained = x
        for y in contained
            name, _quantity = y
            if !haskey(result, name)
                result[name] = []
            end
            push!(result[name], container)
        end
    end

    result
end

function search(parent, color, visited)
    if color in visited
        visited
    else
        push!(visited, color)
        for next in get(parent, color, [])
            search(parent, next, visited)
        end
    end
end

g = graph()
p = parent(g)
visited = Set()
search(p, "shiny gold", visited)

println(length(visited) - 1)
