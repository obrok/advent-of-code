include("../util.jl")

using Pipe
using Printf

function parse_input(lines)
    cells = Set()

    for (x, line) in enumerate(lines)
        for (y, c) in enumerate(line)
            if c == '#'
                push!(cells, (x, y, 0))
            end
        end
    end

    cells
end

function print_cells(cells)
    min_z, max_z = @pipe cells |> collect |> map(x -> x[3], _) |> extrema
    min_x, max_x = @pipe cells |> collect |> map(x -> x[1], _) |> extrema
    min_y, max_y = @pipe cells |> collect |> map(x -> x[2], _) |> extrema

    for z in min_z:max_z
        @printf("z=%d\n", z)
        for x in min_x:max_x
            for y in min_y:max_y
                if (x, y, z) in cells
                    print("#")
                else
                    print(".")
                end
            end
            println()
        end
        println()
    end
end

function evolve(cells, steps)
    for i in 1:steps
        next = Set()

        for c in cells
            for n in neighbors(c)
                n_count = @pipe neighbors(n) |> count(x -> x in cells, _)

                if n in cells && (n_count in 2:3)
                    push!(next, n)
                elseif !(n in cells) && n_count == 3
                    push!(next, n)
                end
            end
        end

        cells = next
    end

    cells
end

function neighbors((x, y, z))
    result = []

    for nx in (x - 1):(x + 1), ny in (y - 1):(y + 1), nz in (z - 1):(z + 1)
        if nx != x || ny != y || nz != z
            push!(result, (nx, ny, nz))
        end
    end

    result
end

@pipe readlines() |> parse_input |> evolve(_, 6) |> length |> println
