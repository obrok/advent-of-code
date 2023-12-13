input = STDIN.gets_to_end.chomp

patterns = input.split("\n\n").map do |pattern|
  pattern.split("\n").map do |line|
    line.split("")
  end
end

part1 = patterns.map do |pattern|
  horizontal, vertical = reflections(pattern)
  score({horizontal.first?, vertical.first?}).not_nil!
end

puts "Part 1: #{part1.sum}"

part2 = patterns.map { |x| find_smudge(x).not_nil! }

puts "Part 2: #{part2.sum}"

def find_smudge(pattern)
  original = reflections(pattern)

  (0...pattern.size).each do |y|
    (0...pattern[0].size).each do |x|
      temp = pattern.clone
      temp[y][x] = flip(temp[y][x])
      new_reflections = reflections(temp)
      new_reflections = {new_reflections[0] - original[0], new_reflections[1] - original[1]}.map { |x| x.first? }

      if new_reflections != {nil, nil}
        return score(new_reflections)
      end
    end
  end

  raise "Should not happen"
end

def flip(char)
  char == "#" ? "." : "#"
end

def score(reflections : {Int32 | Nil, Int32 | Nil})
  horizontal, vertical = reflections
  return 100 * (horizontal + 1) if horizontal
  return vertical + 1 if vertical
end

def reflections(pattern)
  {single_reflections(pattern), single_reflections(pattern.transpose)}
end

def single_reflections(pattern)
  (0...(pattern.size - 1)).select do |y|
    bottom = pattern[..y]
    top = pattern[(y + 1)..]
    size = [bottom.size, top.size].min

    bottom.last(size) == top.first(size).reverse
  end
end
