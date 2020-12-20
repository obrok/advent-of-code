include("../util.jl")

using Pipe

function parse_tile(tile)
    name = match(r"Tile (\d+):", tile[1])[1]
    data = [tile[y][x] for x in 1:length(tile[1]), y in 2:length(tile)]
    parse(Int, name) => data
end

function parse_tiles(lines)
    @pipe lines |> chunk_on(_, "") |> map(parse_tile, _) |> Dict
end

function edges(tiles)
    result = Dict()

    for (name, tile) in tiles
        for x in [1, size(tile, 1)]
            mergewith!(union!, result, Dict(tile[x, :] => Set([name])))
            mergewith!(union!, result, Dict(reverse(tile[x, :]) => Set([name])))
        end
        for x in [1, size(tile, 2)]
            mergewith!(union!, result, Dict(tile[:, x] => Set([name])))
            mergewith!(union!, result, Dict(reverse(tile[:, x]) => Set([name])))
        end
    end

    result
end

function graph(es)
    result = Dict()

    for (_, edge) in es
        if length(edge) == 2
            a, b = collect(edge)
            mergewith!(union!, result, Dict(a => Set([b]), b => Set([a])))
        end
    end

    result
end

function corners(graph)
    @pipe collect(graph) |> filter(pair -> length(pair[2]) == 2, _) |> map(pair -> pair[1], _)
end

readlines() |> parse_tiles |> edges |> graph |> corners |> prod |> println
