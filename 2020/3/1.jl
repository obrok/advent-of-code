tree_map = map(line -> map(x -> x.match, eachmatch(r".", line)), readlines())

right = 0
slope = 3
trees = 0

for row in tree_map
    if row[right % length(row) + 1] == "#"
        global trees += 1
    end
    global right += slope
end

println(trees)
