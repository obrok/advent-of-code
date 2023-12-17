input = STDIN.gets_to_end.chomp

map = input.split("\n").map { |line| line.split("") }

puts "Part 1: #{explore(map, { {1, 0}, {0, 0} })}"

options = map[0].size.times.flat_map do |x|
  [{ {0, 1}, {x, 0} }, { {0, -1}, {x, map.size - 1} }]
end.to_a + map.size.times.flat_map do |y|
  [{ {1, 0}, {0, y} }, { {-1, 0}, {map[0].size - 1, y} }]
end.to_a

puts "Part 2: #{options.map { |x| explore(map, x) }.max}"

def explore(map, start)
  visited = Set({ {Int32, Int32}, {Int32, Int32} }).new
  stack = [start]

  while !stack.empty?
    direction, location = stack.pop
    x, y = location
    dx, dy = direction
    is_horizontal = dy == 0
    key = {location, direction}

    if x < 0 || x >= map[0].size || y < 0 || y >= map.size || visited.includes?(key)
      next
    else
      visited << key
    end

    case map[y][x]
    when "."
      stack.push({ {dx, dy}, {x + dx, y + dy} })
    when "/"
      ndx, ndy = is_horizontal ? {0, -dx} : {-dy, 0}
      stack.push({ {ndx, ndy}, {x + ndx, y + ndy} })
    when "\\"
      ndx, ndy = is_horizontal ? {0, dx} : {dy, 0}
      stack.push({ {ndx, ndy}, {x + ndx, y + ndy} })
    when "-"
      if is_horizontal
        stack.push({ {dx, dy}, {x + dx, y + dy} })
      else
        stack.push({ {1, 0}, {x + 1, y} })
        stack.push({ {-1, 0}, {x - 1, y} })
      end
    when "|"
      if is_horizontal
        stack.push({ {0, 1}, {x, y + 1} })
        stack.push({ {0, -1}, {x, y - 1} })
      else
        stack.push({ {dx, dy}, {x + dx, y + dy} })
      end
    end
  end

  (0...map.size).flat_map do |y|
    (0...map[0].size).count do |x|
      [{1, 0}, {-1, 0}, {0, 1}, {0, -1}].any? { |d| visited.includes?({ {x, y}, d }) }
    end
  end.sum
end
