
include("../util.jl")

using Pipe

_ = parse(UInt32, readline())
busses = @pipe readline() |> split(_, ",") |> map(x -> tryparse(Int64, x), _)
items = []

for i in 1:length(busses)
    if busses[i] != nothing
        push!(items, busses[i] => mod(-i + 1, busses[i]))
    end
end

sort!(items)
reverse!(items)

option = items[1][2]
step = items[1][1]
to_solve = 2
while to_solve <= length(items)
    if option % items[to_solve][1] == items[to_solve][2]
        global step *= items[to_solve][1]
        global to_solve += 1
    else
        global option += step
    end
end
println(option)
