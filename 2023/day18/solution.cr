input = STDIN.gets_to_end.strip.chomp

instructions = input.split("\n").map do |line|
  dir, dist, color = line.split(" ")
  color = color.strip("()#")
  {dir, dist.to_i64, color}
end

puts "Part 1: #{solve(instructions)}"
puts "Part 2: #{solve(instructions.map { |x| decode(x) })}"

def solve(instructions)
  verticals = get_verticals(instructions)
  top = verticals.map { |v| v[2] }.min
  bottom = verticals.map { |v| v[3] }.max
  verticals.sort_by! { |v| v[2] }

  inside_size(top, bottom, verticals) + instructions.map { |x| x[1] }.sum
end

def decode(instruction)
  _, _, color = instruction
  chars = color.split(//)
  dir = case chars.last
        when "0" then "R"
        when "1" then "D"
        when "2" then "L"
        when "3" then "U"
        end
  dist = chars[..-2].join("").to_i64(16)
  {dir.not_nil!, dist, color}
end

def get_verticals(instructions)
  x = 0i64
  y = 0i64
  verticals = [] of {Symbol, Int64, Int64, Int64}
  outside_size = 0i64

  instructions.each do |(dir, dist, _)|
    case dir
    when "R"
      x += dist
      verticals << {:across, x, y, y}
    when "L"
      verticals << {:across, x, y, y}
      x -= dist
    when "D"
      verticals << {:down, x, y, y + dist}
      y += dist
    when "U"
      verticals << {:up, x, y - dist, y}
      y -= dist
    end
  end

  verticals
end

def inside_size(y1, y2, verticals)
  matches = verticals.select { |(_, _, a, b)| (y1..y2).includes?(a) || (a..b).includes?(y1) }.to_a

  if matches.all? { |(_, _, a, b)| (a..b).includes?(y1) && (a..b).includes?(y2) }
    matches.sort_by! { |(dir, x, _, _)| {x, dir} }

    start = nil
    patches = [] of {Int64, Int64}

    matches.each do |(dir, x, _, _)|
      if dir == :up
        start = x
      elsif dir == :down
        if start
          patches << {start + 1, x - 1}
        end
        start = nil
      elsif dir == :across
        start = nil
      end
    end

    width = patches.map { |(a, b)| b - a + 1 }.sum
    width * (y2 - y1 + 1)
  else
    mid = (y1 + y2) // 2
    inside_size(y1, mid, verticals) + inside_size(mid + 1, y2, verticals)
  end
end
