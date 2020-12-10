include("../util.jl")

using Pipe

adapters = @pipe readlines() |> map(x -> parse(UInt32, x), _)
sort!(adapters)
ones = adapters[1] == 1 ? 1 : 0
threes = 1

for i in 2:length(adapters)
    if adapters[i] - adapters[i - 1] == 1
        global ones += 1
    elseif adapters[i] - adapters[i - 1] == 3
        global threes += 1
    end
end

println(ones * threes)
