input = STDIN.gets_to_end.strip.chomp

alias Point = {Int32, Int32}

map = input.split("\n").map { |line| line.split("") }
map[0][1] = "S"
map[map.size - 1][map[0].size - 2] = "E"
source = {1, 0}
sink = {map[0].size - 2, map.size - 1}

queue = [source]
paths = Hash(Point, Array({Point, Int32})).new { [] of {Point, Int32} }
visited = Set.new([source])

while !queue.empty?
  point = queue.shift
  sx, sy = point

  subqueue = case map[sy][sx]
             when "S"
               [{point, 0}]
             when "E"
               next
             else
               [{slide(map[sy][sx], sx, sy), 1}]
             end
  subvisited = Set.new([point, subqueue[0][0]])

  while !subqueue.empty?
    subpoint, dist = subqueue.shift
    x, y = subpoint

    if map[y][x] == "." || map[y][x] == "S"
      [[x + 1, y], [x - 1, y], [x, y + 1], [x, y - 1]].each do |(x1, y1)|
        if y1 > 0 && y1 < map.size && map[y1][x1] != "#" && !subvisited.includes?({x1, y1})
          subqueue.push({ {x1, y1}, dist + 1 })
          subvisited << {x1, y1}
        end
      end
    elsif subpoint != point && (map[y][x] == "E" || !subvisited.includes?(slide(map[y][x], x, y)))
      paths[point] = paths[point] + [{subpoint, dist}]
      if !visited.includes?(subpoint)
        queue << subpoint
        visited << subpoint
      end
    end
  end
end

puts "Part 1: #{longest_path(paths, source, sink)}"

undirected = Hash(Point, Set({Point, Int32})).new { Set({Point, Int32}).new }

map.size.times do |y|
  map[y].size.times do |x|
    explore(map, x, y, undirected) if poi(map, x, y)
  end
end

def poi(map, x, y)
  return false if y < 0 || y >= map.size || x < 0 || x >= map[y].size
  map[y][x] == "S" || map[y][x] == "E" || crossroads(map, x, y)
end

def crossroads(map, x, y)
  return false if map[y][x] == "#"
  [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}].count do |(x1, y1)|
    y1 >= 0 && y1 < map.size && x1 >= 0 && x1 < map[y1].size &&
      map[y1][x1] != "#"
  end > 2
end

res = longest_path_memo(undirected, source, sink, Set.new([source]), Hash({Point, Point, Set(Point)}, Int32).new)
puts "Part 2: #{res}"

def explore(map, sx, sy, undirected)
  queue = [{sx, sy, 0}]
  visited = Set.new([{sx, sy}])

  while !queue.empty?
    x, y, dist = queue.shift

    [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
      .reject { |p| p == {sx, sy} }
      .select { |(x1, y1)| poi(map, x1, y1) || !visited.includes?({x1, y1}) }
      .each do |(x1, y1)|
        if y1 >= 0 && y1 < map.size && x1 >= 0 && x1 < map[y1].size
          if poi(map, x1, y1)
            undirected[{sx, sy}] += Set.new([{ {x1, y1}, dist + 1 }])
          elsif map[y1][x1] != "#"
            queue << {x1, y1, dist + 1}
          end

          visited << {x1, y1}
        end
      end
  end
end

def longest_path_memo(paths, source, sink, visited, memo) : Int32
  key = {source, sink, visited}
  return memo[key] if memo.has_key?(key)
  return 0 if source == sink
  if direct = paths[source].select { |(k, _)| k == sink }.map { |(_, d)| d }.max?
    memo[key] = direct
    return direct
  end

  res = paths[source].reject { |(target, _)| visited.includes?(target) }.map do |(target, dist)|
    longest_path_memo(paths, target, sink, visited + Set.new([target]), memo) + dist
  end.max?

  memo[key] = res || 0
end

def longest_path(paths, source, sink)
  queue = [{source, 0, Set.new([source])}]
  hikes = [] of Int32

  while !queue.empty?
    point, dist, subvisited = queue.shift
    paths[point].each do |target, d|
      if target == sink
        hikes << dist + d
      elsif !subvisited.includes?(target)
        queue << {target, dist + d, subvisited + Set.new([target])}
      end
    end
  end

  hikes.max
end

def slide(char, x, y)
  case char
  when "<"
    {x - 1, y}
  when ">"
    {x + 1, y}
  when "^"
    {x, y - 1}
  when "v"
    {x, y + 1}
  else
    raise "Should not happen"
  end
end
