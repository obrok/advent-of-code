input = STDIN.gets_to_end.split

part1 = input.map do |x|
  f = x[/\d/]
  if l = x.match(/.*(\d)/)
    l = l[1]
  end

  "#{f}#{l}".to_i
end

puts("Part 1: #{part1.sum}")

digit = /(\d|one|two|three|four|five|six|seven|eight|nine|zero)/

part2 = input.map do |x|
  f = x[digit]
  if l = x.match(/.*#{digit}/)
    l = l[1]
  end

  "#{to_digit(f)}#{to_digit(l)}".to_i
end

puts("Part 2: #{part2.sum}")

def to_digit(x)
  {
    "one"   => 1,
    "two"   => 2,
    "three" => 3,
    "four"  => 4,
    "five"  => 5,
    "six"   => 6,
    "seven" => 7,
    "eight" => 8,
    "nine"  => 9,
    "zero"  => 0,
  }.fetch(x, x)
end
