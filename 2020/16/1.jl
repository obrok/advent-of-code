include("../util.jl")

using Pipe

struct Field
    name
    range1
    range2
end

function parse_field(line)
    m = match(r"(.*): (\d+)-(\d+) or (\d+)-(\d+)", line)
    Field(m[1], parse(Int, m[2]) => parse(Int, m[3]), parse(Int, m[4]) => parse(Int, m[5]))
end

function parse_ticket(line)
    @pipe line |> split(_, ",") |> map(x -> parse(Int, x), _)
end

function invalid(fields, x)
    !any(field -> (x >= field.range1[1] && x <= field.range1[2])
        || (x >= field.range2[1] && x <= field.range2[2]), fields)
end

fields, ticker, other_tickets = @pipe readlines() |> chunk_on(_, "")

fields = @pipe fields[2:length(fields)] |> map(parse_field, _)
other_tickets = @pipe other_tickets[2:length(other_tickets)] |> map(parse_ticket, _)

@pipe other_tickets |> reduce(vcat, _) |> filter(x -> invalid(fields, x), _) |> sum |> println
