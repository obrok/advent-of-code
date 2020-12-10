include("../util.jl")

using Pipe

adapters = @pipe readlines() |> map(x -> parse(UInt64, x), _) |> sort
ways = zeros(UInt64, length(adapters))
ways[1] = 1

for i in 2:length(adapters)
    if adapters[i] <= 3
        ways[i] = 1
    end

    for j in (i - 3):(i - 1)
        if j >= 1 && adapters[i] - adapters[j] <= 3
            ways[i] += ways[j]
        end
    end
end

println(last(ways))
