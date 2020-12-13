include("../util.jl")

using Pipe

time = parse(UInt32, readline())
busses = @pipe readline() |> split(_, ",") |> filter(x -> x != "x", _) |> map(x -> parse(UInt32, x), _)
best_time = @pipe busses |> map(x -> x - rem(time, x) => x, _) |> minimum |> prod |> println
