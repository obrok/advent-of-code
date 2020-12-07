include("../util.jl")

using Pipe

function graph()
    function graph_item(line)
        container = match(r"^(.*?) bags", line)[1]
        contents = @pipe line |> eachmatch(r"(\d) (.*?) bags?", _) |> map(function (x)
            x[2] => parse(UInt64, x[1])
        end, _)

        container => Dict(contents)
    end

    @pipe readlines() |> map(graph_item, _) |> Dict
end

function weight(graph, color, cache)
    if haskey(cache, color)
        cache[color]
    else
        result = 1 + @pipe graph[color] |> collect |> map(function item_weight(item)
            inner, quantity = item
            quantity * weight(graph, inner, cache)
        end, _) |> reduce(+, _, init=0)
        cache[color] = result
        result
    end
end

println(weight(graph(), "shiny gold", Dict()) - 1)
