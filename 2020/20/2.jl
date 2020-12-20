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

function build_edges(tiles)
    result = Dict()

    for (name, tile) in tiles
        x = size(tile, 1)
        mergewith!(union!, result, Dict(tile[1, :] => Set([name => :left => false])))
        mergewith!(union!, result, Dict(reverse(tile[1, :]) => Set([name => :left => true])))
        mergewith!(union!, result, Dict(tile[x, :] => Set([name => :right => false])))
        mergewith!(union!, result, Dict(reverse(tile[x, :]) => Set([name => :right => true])))
        mergewith!(union!, result, Dict(tile[:, 1] => Set([name => :bottom => false])))
        mergewith!(union!, result, Dict(reverse(tile[:, 1]) => Set([name => :bottom => true])))
        mergewith!(union!, result, Dict(tile[:, x] => Set([name => :top => false])))
        mergewith!(union!, result, Dict(reverse(tile[:, x]) => Set([name => :top => true])))
    end

    result
end

function build_graph(es)
    result = Dict()

    for (_, edge) in es
        if length(edge) == 2
            (a, (a_dir, a_orient)), (b, (b_dir, b_orient)) = collect(edge)
            mergewith!(merge!, result, Dict(
                a => Dict(a_dir => (b, b_dir, xor(a_orient, b_orient))),
                b => Dict(b_dir => (a, a_dir, xor(a_orient, b_orient)))
            ))
        end
    end

    result
end

function corners(graph)
    @pipe collect(graph) |> filter(pair -> length(pair[2]) == 2, _) |> map(pair -> pair[1], _)
end

function opposite(direction)
    Dict(:bottom => :top, :top => :bottom, :left => :right, :right => :left)[direction]
end

function print_tile(tile)
    for y in reverse(1:size(tile, 2))
        for x in 1:size(tile, 1)
            print(tile[x, y])
        end
        println()
    end
    println()
end

function orient(right, down, tile)
    tester = [:top :right; :left :bottom]
    while tester[1,2] != right
        tester = rotr90(tester)
        tile = rotr90(tile)
    end

    tester[2,2] == down ? tile : reverse(tile, dims=2)
end

function right_edge(tile)
    tile[size(tile, 1), :]
end

function left_edge(tile)
    tile[1, :]
end

function bottom_edge(tile)
    tile[:, 1]
end

function top_edge(tile)
    tile[:, size(tile, 2)]
end

function trim_edge(tile)
    tile[2:(size(tile, 1) - 1), 2:(size(tile, 2) - 1)]
end

function rotations(tile)
    result = []
    for _ in 1:4
        push!(result, tile)
        push!(result, reverse(tile, dims=1))
        push!(result, reverse(tile, dims=2))
        tile = rotr90(tile)
    end
    result
end

function orient_to(tile, edge, edge_fun)
    @pipe rotations(tile) |> filter(x -> edge_fun(x) == edge, _) |> first
end

function build_picture(tiles, graph)
    row_start = graph |> corners |> first
    right, down = graph[row_start] |> keys
    oriented = orient(right, down, tiles[row_start])
    rows = []

    while true
        push!(rows, build_row(tiles, oriented, row_start, right, graph))
        if haskey(graph[row_start], down)
            row_start, from, _ = graph[row_start][down]
            down = opposite(from)
            right = @pipe graph[row_start] |> keys |> setdiff(_, [from, down]) |> first
            oriented = orient_to(tiles[row_start], bottom_edge(oriented), top_edge)
        else
            break;
        end
    end

    foldl(hcat, reverse(rows))
end

function build_row(tiles, oriented, current, right, graph)
    result = []

    while true
        push!(result, oriented)
        if haskey(graph[current], right)
            current, from, _ = graph[current][right]
            right = opposite(from)
            oriented = orient_to(tiles[current], right_edge(oriented), left_edge)
        else
            break;
        end
    end

    @pipe result |> map(trim_edge, _) |> foldl(vcat, _)
end

function matches_pattern(picture, pattern, x, y)
    for i in 1:size(pattern, 1), j in 1:size(pattern, 2)
        if pattern[i, j] == '#' && picture[x + i - 1, y + j - 1] != '#'
            return false
        end
    end

    return true
end

function locations(picture, pattern)
    result = []
    for x in 1:(size(picture, 1) - size(pattern, 1) + 1), y in 1:(size(picture, 2) - size(pattern, 2) + 1)
        if matches_pattern(picture, pattern, x, y)
            push!(result, (x, y))
        end
    end
    result
end

function clean_pattern(picture, pattern)
    for (x, y) in locations(picture, pattern)
        for i in 1:size(pattern, 1), j in 1:size(pattern, 2)
            if pattern[i, j] == '#'
                picture[x + i - 1, y + j - 1] = 'O'
            end
        end
    end
end

tiles = readlines() |> parse_tiles
graph = tiles |> build_edges |> build_graph
pictures = build_picture(tiles, graph) |> rotations

pattern = [
    "                  # ",
    "#    ##    ##    ###",
    " #  #  #  #  #  #   ",
]
pattern = [pattern[y][x] for x in 1:length(pattern[1]), y in 1:length(pattern)]

picture = @pipe pictures |> filter(x -> length(locations(x, pattern)) > 0, _) |> first
clean_pattern(picture, pattern)
count(x -> x == '#', picture) |> println
