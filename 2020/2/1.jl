valid = 0

for line in eachline()
    policy, password = split(line, ": ")
    number, letter = split(policy, " ")
    lo, hi = split(number, "-")
    lo = parse(UInt32, lo)
    hi = parse(UInt32, hi)

    cnt = count(x -> x.match == letter, eachmatch(r".", password))

    if cnt >= lo && cnt <= hi
        global valid += 1
    end
end

println(valid)
