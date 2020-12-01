data = map((x) -> parse(UInt32, x), readlines())

for a in data
    for b in data
        if a + b == 2020
            println(a * b)
        end
    end
end
