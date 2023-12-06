input = STDIN.gets_to_end.chomp
seeds, *maps = input.split("\n\n")
seeds = seeds.split(":")[1].chomp.split.map(&.to_i64)

single_seeds = seeds
maps = maps.map do |map|
  _, *map = map.split("\n")
  map = map.map do |line|
    out_lo, in_lo, size = line.chomp.split.map(&.to_i64)
    {out_lo, SRange.new(in_lo, in_lo + size - 1)}
  end
  map.sort_by { |x| x[1].lo }
end

maps.each do |map|
  single_seeds = single_seeds.map do |seed|
    mapping = map.find { |mapping| mapping[1].lo <= seed && mapping[1].lo + mapping[1].size > seed }
    mapping ? mapping[0] + seed - mapping[1].lo : seed
  end
end

puts "Part 1: #{single_seeds.min}"

seed_ranges = seeds.map(&.to_i64).each_slice(2).map { |x| SRange.new(x[0], x[0] + x[1] - 1) }.to_a

seed_ranges = maps.reduce(seed_ranges) do |seed_ranges, map|
  result = [] of SRange

  seed_ranges.each do |range|
    map.each do |(out_lo, in_range)|
      bottom, range = range.cut_at(in_range.lo)
      result << bottom

      cut, range = range.cut_at(in_range.hi + 1)
      cut = cut.move_by(out_lo - in_range.lo)
      result << cut
    end

    result << range
  end

  result.reject(&.empty?)
end

puts "Part 2: #{seed_ranges.map(&.lo).min}"

class SRange
  getter lo : Int64
  getter hi : Int64

  def self.empty
    SRange.new(0, -1)
  end

  def initialize(lo, hi)
    @lo = lo
    @hi = hi
  end

  def size
    hi - lo + 1
  end

  def empty?
    size <= 0
  end

  def cut_at(point : Int64)
    if point < lo
      {SRange.empty, self}
    elsif point > hi
      {self, SRange.empty}
    else
      {SRange.new(lo, point - 1), SRange.new(point, hi)}
    end
  end

  def move_by(by : Int64)
    SRange.new(lo + by, hi + by)
  end
end
