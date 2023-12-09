input = STDIN.gets_to_end.chomp

predictions = input.split("\n").map do |line|
  numbers = line.split(" ").map(&.to_i)
  predict(numbers)
end

puts "Part 1: #{predictions.map { |x| x[1] }.sum}"
puts "Part 2: #{predictions.map { |x| x[0] }.sum}"

def predict(numbers)
  if numbers.all? { |n| n == 0 }
    {0, 0}
  else
    diffs = numbers.each_cons(2).map { |(a, b)| b - a }.to_a
    p1, p2 = predict(diffs)
    {numbers.first - p1, numbers.last + p2}
  end
end
