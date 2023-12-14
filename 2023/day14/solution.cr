input = STDIN.gets_to_end.chomp

map = input.split("\n").map { |line| line.split("") }

part1 = map.clone
slide_up(part1)

puts "Part 1: #{load(part1)}"

target = 1000000000
hashes = Set(UInt64).new

while !hashes.includes?(map.hash)
  hashes << map.hash
  map = cycle(map)
end

init = hashes.size
hashes = Set(UInt64).new

while !hashes.includes?(map.hash)
  hashes << map.hash
  map = cycle(map)
end

cycle_length = hashes.size
target = (target - init) % cycle_length

target.times do
  map = cycle(map)
end

puts "Part 2: #{load(map)}"

def cycle(map)
  4.times do
    slide_up(map)
    map = rotate(map)
  end

  map
end

def rotate(map)
  (0...map[0].size).map do |x|
    (0...map.size).map do |y|
      map[y][x]
    end.reverse
  end
end

def load(map)
  (0...map.size).flat_map do |y|
    (0...map[y].size).map do |x|
      map[y][x] == "O" ? map.size - y : 0
    end
  end.sum
end

def slide_up(map)
  (0...map.size).each do |y|
    (0...map[y].size).each do |x|
      y2 = y
      while y2 > 0 && map[y2][x] == "O" && map[y2 - 1][x] == "."
        map[y2][x] = "."
        map[y2 - 1][x] = "O"
        y2 -= 1
      end
    end
  end
end
