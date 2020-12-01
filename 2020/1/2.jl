data = map((x) -> parse(UInt32, x), readlines())

for a in data
    for b in data
        for c in data
            if a + b + c == 2020
                println(a * b * c)
            end
        end
    end
end
