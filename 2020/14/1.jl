include("../util.jl")

using Pipe

struct Mask
    ones::Int64
    zeros::Int64
end

struct Set
    loc::Int64
    val::Int64
end

mutable struct State
    mask::Mask
    mem::Dict{Int64,Int64}
end

function parse_line(line)
    m = match(r"mask = (.*)", line)
    if m != nothing
        ones = @pipe m[1] |> replace(_, 'X' => '0') |> parse(Int64, _, base=2)
        zeros = @pipe m[1] |> replace(_, 'X' => '1', ) |> parse(Int64, _, base=2)
        Mask(ones, zeros)
    else
        m = match(r"mem\[(.*)\] = (.*)", line)
        Set(parse(Int64, m[1]), parse(Int64, m[2]))
    end
end

function run(program)
    state = State(Mask(0, 0), Dict())

    for instruction in program
        apply(instruction, state)
    end

    state.mem |> values |> sum
end

function apply(mask::Mask, state)
    state.mask = mask
end

function apply(set::Set, state)
    state.mem[set.loc] = (set.val | state.mask.ones) & state.mask.zeros
end

@pipe readlines() |> map(parse_line, _) |> run |> println
