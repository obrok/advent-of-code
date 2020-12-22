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
all_suspect = mapreduce(a -> suspects(foods, a), union, allergens)
ingredients = mapreduce(food -> food[1], union, foods)

mapreduce(food -> setdiff(food[1], all_suspect) |> collect, vcat, foods) |> length |> println
