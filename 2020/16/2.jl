include("../util.jl")

using Pipe

mutable struct Field
    name
    range1
    range2
    positions
    position
end

function parse_field(line)
    m = match(r"(.*): (\d+)-(\d+) or (\d+)-(\d+)", line)
    Field(m[1], parse(Int, m[2]) => parse(Int, m[3]), parse(Int, m[4]) => parse(Int, m[5]), nothing, nothing)
end

function parse_ticket(line)
    @pipe line |> split(_, ",") |> map(x -> parse(Int, x), _)
end

function field_match(field, value)
    (value >= field.range1[1] && value <= field.range1[2]) ||
        (value >= field.range2[1] && value <= field.range2[2])
end

function valid(fields, ticket)
    all(value -> any(field -> field_match(field, value), fields), ticket)
end

fields, ticket, other_tickets = @pipe readlines() |> chunk_on(_, "")

fields = @pipe fields[2:length(fields)] |> map(parse_field, _)
valid_tickets = @pipe other_tickets[2:length(other_tickets)] |>
    map(parse_ticket, _) |>
    filter(x -> valid(fields, x), _)
all_tickets = [[parse_ticket(ticket[2])]; valid_tickets]

for field in fields
    field.positions = @pipe 1:length(all_tickets[1]) |>
        filter(i -> all(ticket -> field_match(field, ticket[i]), all_tickets), _)
end

sort!(fields, by=x -> length(x.positions))
used = []

for field in fields
    field.position = setdiff(field.positions, used)
    global used = field.positions
end

@pipe fields |> filter(x -> startswith(x.name, "departure"), _) |>
    mapreduce(x -> all_tickets[1][x.position], vcat, _) |> prod |> println
