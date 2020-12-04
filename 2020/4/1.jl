using Pipe

item = Dict{String,String}()
passports = []

for line in readlines()
    if line == ""
        push!(passports, item)
        global item = Dict{String,String}()
    else
        for pair in eachmatch(r"[^ ]*:[^ ]*", line)
            key, value = split(pair.match, ":")
            global item[key] = value
        end
    end
end

required = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]
@pipe passports |> count(x -> all(key -> haskey(x, key), required), _) |> println
