include("../util.jl")

using Pipe

function parse_rules(rules)
    map(x -> match(r"(\d+): (.*)", x).captures, rules) |> Dict
end

function build_regex(rules, rule_name="0")
    rule = rules[rule_name]
    single = match(r"\"(.)\"", rule)
    if rule_name == "8"
        "(" * build_regex(rules, "42") * "+)"
    elseif rule_name == "11"
        "(?<g11>" * build_regex(rules, "42") * "(?&g11)?" * build_regex(rules, "31") * ")"
    elseif single !== nothing
        single[1]
    else
        contents = @pipe split(rule, " ") |> chunk_on(_, "|") |> map(part ->
            "(" * join(map(x -> build_regex(rules, x), part), "") * ")"
        , _) |> join(_, "|")
        "(" * contents * ")"
    end
end

rules, messages = @pipe readlines() |> chunk_on(_, "")
regex = @pipe rules |> parse_rules |> build_regex |> Regex("^" * _ * "\$")
count(x -> occursin(regex, x), messages) |> println
