using Pipe

item = Dict{String,String}()
passports = []

for line in readlines()
    if line == ""
        push!(passports, item)
        global item = Dict{String,String}()
    else
        for pair in split(line, " ")
            key, value = split(pair, ":")
            global item[key] = value
        end
    end
end

push!(passports, item)

function number_between(string, from, to)
    number = tryparse(UInt32, string)
    number != nothing && number >= from && number <= to
end

function valid_height(height)
    parsed = match(r"^([\d]+)(in|cm)$", height)
    parsed != nothing && (
        (parsed[2] == "in" && number_between(parsed[1], 59, 76)) ||
        (parsed[2] == "cm" && number_between(parsed[1], 150, 193)))
end

function valid_color(color)
    match(r"^#[a-f0-9]{6}$", color) != nothing
end

function valid_eye_color(color)
    color in ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]
end

function valid_pid(pid)
    match(r"^\d{9}$", pid) != nothing
end

function valid(passport)
    number_between(get(passport, "byr", ""), 1920, 2002) &&
    number_between(get(passport, "iyr", ""), 2010, 2020) &&
    number_between(get(passport, "eyr", ""), 2020, 2030) &&
    valid_height(get(passport, "hgt", "")) &&
    valid_color(get(passport, "hcl", "")) &&
    valid_eye_color(get(passport, "ecl", "")) &&
    valid_pid(get(passport, "pid", ""))
end

@pipe passports |> count(valid, _) |> println
