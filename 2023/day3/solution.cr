schematic = STDIN.gets_to_end.chomp.split('\n').map do |line|
  line.split("")
end

y = 0
numbers = [] of Array({Int32, Int32})

while y < schematic.size
  x = 0

  while x < schematic[y].size
    number = [] of {Int32, Int32}

    while x < schematic[y].size && schematic[y][x] =~ /\d/
      number << {x, y}
      x += 1
    end

    if number.size > 0
      numbers << number
    else
      x += 1
    end
  end

  y += 1
end

part_numbers = numbers.select do |number|
  number.any? do |(x, y)|
    Neighbors.new(x, y).any? do |(xp, yp)|
      xp >= 0 && yp >= 0 && xp < schematic[y].size && yp < schematic.size && schematic[yp][xp] !~ /\d|\./
    end
  end
end

by_location = {} of {Int32, Int32} => { {Int32, Int32}, Int32 }

values = part_numbers.map do |number|
  value = number.map do |(x, y)|
    schematic[y][x]
  end.join("").to_i

  number.each do |(x, y)|
    by_location[{x, y}] = {number[0], value}
  end

  value
end

puts("Part 1: #{values.sum}")

cog_ratios = (0...schematic.size).flat_map do |y|
  (0...schematic[y].size).map do |x|
    if schematic[y][x] == "*"
      cog_numbers = Set({ {Int32, Int32}, Int32 }).new

      Neighbors.new(x, y).each do |(xp, yp)|
        if by_location.has_key?({xp, yp})
          cog_numbers << by_location[{xp, yp}]
        end
      end

      if cog_numbers.size == 2
        cog_numbers.map(&.last).product
      end
    end
  end
end.compact

puts("Part 2: #{cog_ratios.sum}")

class Neighbors
  include Enumerable({Int32, Int32})

  def initialize(x : Int32, y : Int32)
    @x = x
    @y = y
  end

  def each
    (-1..1).each do |dx|
      (-1..1).each do |dy|
        next if dx == 0 && dy == 0
        yield({@x + dx, @y + dy})
      end
    end
  end
end
