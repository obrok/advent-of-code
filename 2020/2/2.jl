valid = 0

for line in eachline()
    policy, password = split(line, ": ")
    number, letter = split(policy, " ")
    lo, hi = split(number, "-")
    lo = parse(UInt32, lo)
    hi = parse(UInt32, hi)

    cnt = count(x -> x == first(letter), [password[lo], password[hi]])

    if cnt == 1
        global valid += 1
    end
end

println(valid)
