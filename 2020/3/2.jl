tree_map = map(line -> map(x -> x.match, eachmatch(r".", line)), readlines())

function trees(tree_map, right, down)
    count = 0
    x = 0
    y = 1

    while y <= length(tree_map)
        row = tree_map[y]

        if row[x % length(row) + 1] == "#"
            count += 1
        end

        x += right
        y += down
    end

    count
end

total = 1

for slope in [[1, 1], [3, 1], [5, 1], [7, 1], [1, 2]]
    right, down = slope
    global total *= trees(tree_map, right, down)
end

println(total)

