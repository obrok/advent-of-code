data = STDIN.gets_to_end.chomp.split('\n').map do |line|
  _, items = line.split(':')
  win, have = items.split('|')
  have = Set.new(have.split.map(&.to_i))
  win = Set.new(win.split.map(&.to_i))
  [win, have]
end

scores = data.map do |(win, have)|
  hits = (win & have).size
  if hits > 0
    2 ** (hits - 1)
  else
    0
  end
end

puts "Part 1: #{scores.sum}"

counts = [1] * data.size
(0...data.size).each do |i|
  win, have = data[i]
  hits = (win & have).size
  (0...hits).each do |j|
    counts[i + j + 1] += counts[i]
  end
end

puts "Part 2: #{counts.sum}"
