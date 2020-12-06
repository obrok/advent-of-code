include("../util.jl")

using Pipe

@pipe readlines() |> chunk_on(_, "") |> mapreduce(ls -> reduce(union, ls) |> length, +, _) |> println
