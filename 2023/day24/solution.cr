require "big"

input = STDIN.gets_to_end.strip.chomp

alias Point = {x: Int64, y: Int64, z: Int64}
alias Stone = {pos: Point, v: Point}

stones = input.split("\n").map do |line|
  pos, v = line.split(" @ ")
  pos = pos.split(", ").map { |x| BigRational.new(x.to_big_i) }
  v = v.split(", ").map { |x| BigRational.new(x.to_big_i) }
  {pos: {x: pos[0], y: pos[1], z: pos[2]}, v: {x: v[0], y: v[1], z: v[2]}}
end

epsilon = BigRational.new(1e-12)
lo_bound = BigRational.new(200000000000000i64)
hi_bound = BigRational.new(400000000000000i64)
cross_count = 0

stones.each do |stone1|
  stones.each do |stone2|
    next if stone1 == stone2

    intersection = find_intersection(stone1, stone2)
    if intersection && future?(intersection, stone1) && future?(intersection, stone2) &&
       inside?(intersection, lo_bound, hi_bound)
      cross_count += 1
    end
  end
end

puts "Part 1: #{cross_count // 2}"

z = 242720827369528
z_speed = 81
points = [stones[0], stones[1]].map do |stone|
  t = (stone[:pos][:z] - z) / (z_speed - stone[:v][:z])
  x = stone[:pos][:x] + t * stone[:v][:x]
  y = stone[:pos][:y] + t * stone[:v][:y]
  [x, y, t]
end

x_speed = -(points[1][0] - points[0][0]) / (points[0][2] - points[1][2])
y_speed = -(points[1][1] - points[0][1]) / (points[0][2] - points[1][2])

t0 = points[0][2]
x0 = stones[0][:pos][:x] + t0 * stones[0][:v][:x]
x = x0 - x_speed * t0
y0 = stones[0][:pos][:y] + t0 * stones[0][:v][:y]
y = y0 - y_speed * t0
puts "Part 2: #{[x, y, z].sum}"

def inside?(intersection, lo_bound, hi_bound)
  intersection[0] >= lo_bound && intersection[0] <= hi_bound &&
    intersection[1] >= lo_bound && intersection[1] <= hi_bound
end

def future?(intersection, stone)
  (intersection[0] < stone[:pos][:x]) == (stone[:v][:x] < 0) &&
    (intersection[1] < stone[:pos][:y]) == (stone[:v][:y] < 0)
end

def find_intersection(stone1, stone2)
  a1 = stone1[:v][:y] / stone1[:v][:x]
  a2 = stone2[:v][:y] / stone2[:v][:x]
  b1 = stone1[:pos][:y] - a1 * stone1[:pos][:x]
  b2 = stone2[:pos][:y] - a2 * stone2[:pos][:x]

  if a1 == a2
    return nil
  else
    x = (b2 - b1) / (a1 - a2)
    y = a1 * x + b1
    return {x, y}
  end
end
