include("../util.jl")

using Pipe

starting = [20,0,1,11,6,3]

numbers = Dict()
for (i, number) in enumerate(starting)
    numbers[number] = i
end

next = 0
for i in (length(starting) + 1):(30000000 - 1)
    nextnext = haskey(numbers, next) ? i - numbers[next] : 0
    numbers[next] = i
    global next = nextnext
end

println(next)
