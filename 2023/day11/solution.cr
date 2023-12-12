input = STDIN.gets_to_end.chomp

map = input.split("\n").map { |line| line.split("") }

stars = (0...map.size).flat_map do |y|
  (0...map[0].size).map do |x|
    {x.to_i64, y.to_i64} if map[y][x] == "#"
  end
end.compact

y_expansion = (0...map.size).select do |y|
  map[y].all? { |c| c == "." }
end

x_expansion = (0...map[0].size).select do |x|
  map.all? { |line| line[x] == "." }
end

def expanded_distances(x_expansion, y_expansion, stars, factor)
  expansion_stars = stars.map do |(x, y)|
    x = x + (factor - 1) * x_expansion.count { |x2| x2 < x }
    y = y + (factor - 1) * y_expansion.count { |y2| y2 < y }
    {x, y}
  end

  expansion_stars.flat_map do |s1|
    expansion_stars.map do |s2|
      if s1 < s2
        (s1[0] - s2[0]).abs + (s1[1] - s2[1]).abs
      end
    end
  end.compact
end

puts "Part 1: #{expanded_distances(x_expansion, y_expansion, stars, 2).sum}"
puts "Part 2: #{expanded_distances(x_expansion, y_expansion, stars, 1000000).sum}"
