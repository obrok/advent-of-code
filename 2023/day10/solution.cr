input = STDIN.gets_to_end.chomp

map = input.split("\n").map do |line|
  line.split(//)
end

y = map.index { |row| row.any? { |c| c == "S" } } || raise "Unexpected"
x = map[y].index("S") || raise "Unexpected"

directions = {
  "|" => [{0, -1}, {0, 1}],
  "-" => [{-1, 0}, {1, 0}],
  "F" => [{0, 1}, {1, 0}],
  "7" => [{-1, 0}, {0, 1}],
  "J" => [{0, -1}, {-1, 0}],
  "L" => [{1, 0}, {0, -1}],
}

dir = [{0, 1}, {0, -1}, {1, 0}, {-1, 0}].find do |(dx, dy)|
  nx = x + dx
  ny = y + dy
  if nx >= 0 && nx < map[0].size && ny >= 0 && ny < map.size
    directions[map[ny][nx]].includes?({-dx, -dy})
  end
end || raise "Unexpected"

loop = Set({Int32, Int32}).new
left_turns = 0
right_turns = 0
left = Set({Int32, Int32}).new
right = Set({Int32, Int32}).new
while true
  loop.add({x, y})
  x = x + dir[0]
  y = y + dir[1]

  if map[y][x] == "S"
    break
  end

  dirs = directions[map[y][x]]
  dir = dirs.find { |d| d != {-dir[0], -dir[1]} } || raise "Unexpected"

  if ["F", "7", "J", "L"].includes?(map[y][x])
    d1, d2 = directions[map[y][x]]
    inside = {x + d1[0] + d2[0], y + d1[1] + d2[1]}
    outside = [
      {x - d1[0], y - d1[1]},
      {x - d2[0], y - d2[1]},
      {x - d1[0] - d2[0], y - d1[1] - d2[1]},
    ]

    if dir == d1
      left_turns += 1
      left << inside
      outside.each { |p| right << p }
    else
      right_turns += 1
      right << inside
      outside.each { |p| left << p }
    end
  end
end

puts "Part 1: #{loop.size // 2}"

to_visit = left_turns > right_turns ? left : right
to_visit = (Set.new(to_visit) - loop).to_a
visited = Set({Int32, Int32}).new

while !to_visit.empty?
  x, y = to_visit.shift
  visited.add({x, y})

  [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}].each do |(x, y)|
    if !loop.includes?({x, y}) && !visited.includes?({x, y})
      to_visit.push({x, y})
    end
  end
end

puts "Part 2: #{visited.size}"
