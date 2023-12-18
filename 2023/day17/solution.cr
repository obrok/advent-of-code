require "priority-queue"

input = STDIN.gets_to_end.chomp

map = input.split("\n").map { |line| line.split("").map(&.to_i) }

puts "Part 1: #{explore(map, 1, 3)}"
puts "Part 2: #{explore(map, 4, 10)}"

def explore(map, min_move, max_move)
  queue = Priority::Queue({ {Int32, Int32}, {Int32, Int32} }).new
  queue.push(0, { {0, 0}, {1, 0} })
  queue.push(0, { {0, 0}, {0, 1} })
  visited = Set({ {Int32, Int32}, {Int32, Int32} }).new

  while !queue.empty?
    item = queue.pop
    cost = item.priority
    value = item.value
    location, direction = value
    x, y = location
    dx, dy = direction

    if visited.includes?(value)
      next
    else
      visited.add(value)
    end

    if x == map[0].size - 1 && y == map.size - 1
      return -cost
    end

    dc = 0
    (1..max_move).each do |i|
      nx = x + dx * i
      ny = y + dy * i

      if nx >= 0 && nx < map[0].size && ny >= 0 && ny < map.size
        dc += map[ny][nx]
        if i >= min_move
          queue.push(cost - dc, { {nx, ny}, rot_left(direction) })
          queue.push(cost - dc, { {nx, ny}, rot_right(direction) })
        end
      end
    end
  end
end

def rot_left(direction)
  dx, dy = direction
  {-dy, dx}
end

def rot_right(direction)
  dx, dy = direction
  {dy, -dx}
end
