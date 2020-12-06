include("../util.jl")

using Pipe

@pipe readlines() |> chunk_on(_, "") |> mapreduce(ls -> reduce(intersect, ls) |> length, +, _) |> println
