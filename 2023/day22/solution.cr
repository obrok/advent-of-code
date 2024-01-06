input = STDIN.gets_to_end.strip.chomp

alias Point = {Int32, Int32, Int32}
alias Block = {Point, Point}

blocks = input.split.map do |line|
  from, to = line.split("~")
  from, to = [from, to].map { |point| point.split(",").map(&.to_i) }
  from, to = [from, to].sort
  { {from[0], from[1], from[2]}, {to[0], to[1], to[2]} }
end

floor = Hash({Int32, Int32}, Int32).new(0)
structure = {} of Point => Block
blocks.sort_by! { |(from, to)| [from[2], to[2]].min }
supports = Hash(Block, Set(Block)).new { Set(Block).new }
leans_on = Hash(Block, Set(Block)).new { Set(Block).new }

blocks.each do |block|
  bottom = bottom(block)
  points = points(block)
  rest_z = points.map { |(x, y, z)| floor[{x, y}] }.max
  rest = points.map { |(x, y, z)| {x, y, rest_z + z - bottom + 1} }
  rest.each do |(x, y, z)|
    floor[{x, y}] = [floor[{x, y}], z].max
    structure[{x, y, z}] = block
  end

  rest.each do |(x, y, z)|
    if structure.has_key?({x, y, z - 1}) && structure[{x, y, z - 1}] != block
      supports[structure[{x, y, z - 1}]] += Set.new([block])
      leans_on[block] += Set.new([structure[{x, y, z - 1}]])
    end
  end
end

blocks.count do |block|
  res = supports[block].all? do |supported|
    leans_on[supported].size > 1
  end
  res
end.tap { |result| puts "Part 1: #{result}" }

blocks.map do |block|
  would_fall(block, supports, leans_on)
end.sum.tap { |result| puts "Part 2: #{result}" }

def would_fall(block, supports, leans_on)
  fallen = Set.new([block])
  to_check = supports[block].to_a

  while !to_check.empty?
    block = to_check.pop
    if (leans_on[block] - fallen).empty?
      fallen << block
      supports[block].each { |supported| to_check << supported }
    end
  end

  fallen.size - 1
end

def bottom(block)
  [block[0][2], block[1][2]].min
end

def points(block)
  from, to = block
  (from[0]..to[0]).flat_map do |x|
    (from[1]..to[1]).flat_map do |y|
      (from[2]..to[2]).map do |z|
        {x, y, z}
      end
    end
  end
end
