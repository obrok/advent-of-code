include("../util.jl")

using Pipe

function code()
    function parse_line(line)
        ins, arg = split(line, " ")
        ins => parse(Int32, arg)
    end

    @pipe readlines() |> map(parse_line, _)
end

function run(code)
    acc = 0
    insp = 1
    visited = Set()

    while true
        if insp in visited
            return nothing
        elseif insp == length(code) + 1
            return acc
        end
        push!(visited, insp)

        ins, arg = code[insp]

        if ins == "nop"
            insp += 1
        elseif ins == "acc"
            acc += arg
            insp += 1
        else
            insp += arg
        end
    end
end

function modifications(code)
    result = []

    for i in 1:length(code)
        mod = copy(code)
        ins, arg = mod[i]

        if ins == "nop"
            mod[i] = "jmp" => arg
            push!(result, mod)
        elseif ins == "jmp"
            mod[i] = "nop" => arg
            push!(result, mod)
        end
    end

    result
end

@pipe code() |> modifications |> map(run, _) |> filter(x -> x != nothing, _) |> println
