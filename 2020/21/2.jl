include("../util.jl")

using Pipe

function parse_food(line)
    m = match(r"(.*) \(contains (.*)\)", line)
    Set(split(m[1], " ")) => Set(split(m[2], ", "))
end

function suspects(foods, allergen)
    @pipe foods |> filter(food -> allergen in food[2], _) |> mapreduce(food -> food[1], intersect, _)
end

foods = map(parse_food, readlines())
allergens = mapreduce(food -> food[2], union, foods)
all_suspect = @pipe allergens |> collect |> map(a -> a => suspects(foods, a), _) |> Dict

while !all(x -> length(x[2]) == 1, all_suspect)
    known = @pipe all_suspect |> values |> collect |> filter(x -> length(x) == 1, _) |> reduce(union, _)
    for (key, options) in all_suspect
        if length(options) != 1
            all_suspect[key] = setdiff(options, known)
        end
    end
end

@pipe all_suspect |> collect |> sort(_, by=first) |> map(x -> first(x[2]), _) |> join(_, ",") |> println
