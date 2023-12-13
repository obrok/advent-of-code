require "big"

input = STDIN.gets_to_end.chomp
lines = input.split("\n")

part1 = lines.map do |line|
  pattern, groups = line.split(" ")
  pattern = pattern.split(//)
  groups = groups.split(",").map(&.to_i)
  {pattern, groups}
end

part2 = lines.map do |line|
  pattern, groups = line.split(" ")
  pattern = ([pattern] * 5).join("?").split(//)
  groups = groups.split(",").map(&.to_i) * 5
  {pattern, groups}
end

puts "Part 1: #{all_options(part1)}"
puts "Part 2: #{all_options(part2)}"

def all_options(patterns)
  patterns.map do |(pattern, groups)|
    cache = {} of {Array(String), Array(Int32)} => BigInt
    options(pattern, groups, cache)
  end.sum
end

def options(pattern, groups, cache)
  if groups.empty?
    cache[{pattern, groups}] = BigInt.new(pattern.all? { |c| c == "?" || c == "." } ? 1 : 0)
  elsif pattern.empty?
    cache[{pattern, groups}] = BigInt.new(groups.empty? ? 1 : 0)
  elsif !cache.has_key?({pattern, groups})
    first, *rest = groups

    if first == pattern.size
      cache[{pattern, groups}] = BigInt.new(pattern.all? { |c| c == "?" || c == "#" } && groups.size == 1 ? 1 : 0)
    elsif first > pattern.size
      cache[{pattern, groups}] = BigInt.new(0)
    else
      res = BigInt.new(0)

      if pattern[0] == "?" || pattern[0] == "."
        res += options(pattern[1..], groups, cache)
      end
      if pattern[...first].all? { |c| c == "?" || c == "#" } &&
         (pattern[first] == "?" || pattern[first] == ".")
        res += options(pattern[(first + 1)..], rest, cache)
      end
      cache[{pattern, groups}] = res
    end
  end

  cache[{pattern, groups}]
end
