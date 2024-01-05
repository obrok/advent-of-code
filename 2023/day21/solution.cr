input = STDIN.gets_to_end.strip.chomp

map = input.split("\n").map { |line| line.split("") }
y = map.index { |line| line.includes?("S") }.not_nil!
x = map[y].index("S").not_nil!

cycle_length = 131
init_length = 65
dist = distances(map, x, y, init_length + 3 * cycle_length)

(0..64).select(&.even?).map { |i| dist[i] }.sum.tap { |v| puts "Part 1: #{v}" }

init_deviation = (0..init_length).map { |i| dist[i] - 4 * i }.to_a
deviation = cycle_length.times.map { |i| dist[i + init_length + 1] - 4 * (i + init_length + 1) }.to_a

target = 26501365
total = (0..target).select(&.odd?).map do |i|
  res = 4 * i

  if i <= init_length
    res += init_deviation[i]
  else
    cycle_no = (i - init_length - 1) // cycle_length + 1
    cycle_pos = (i - init_length - 1) % cycle_length
    res += deviation[cycle_pos.to_i32] * cycle_no
  end

  res.to_i64
end.sum

puts "Part 2: #{total}"

def distances(map, start_x, start_y, max_steps)
  queue = [{0, 0, 0i64}]
  visited = Set.new([{0, 0}])
  counts = Hash(Int64, Int64).new(0i64)

  while !queue.empty?
    x, y, d = queue.pop
    break if d > max_steps
    counts[d] += 1

    [[x + 1, y], [x - 1, y], [x, y + 1], [x, y - 1]].each do |(x1, y1)|
      if map[(y1 + start_y) % map[0].size][(x1 + start_y) % map.size] != "#" && !visited.includes?({x1, y1})
        queue.unshift({x1, y1, d + 1})
        visited << {x1, y1}
      end
    end
  end

  counts
end
