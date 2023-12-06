input = STDIN.gets_to_end.chomp
times, distances = input.split("\n")
times = times.split(":")[1].strip.split(/ +/).map(&.chomp.to_i)
distances = distances.split(":")[1].strip.split(/ +/).map(&.chomp.to_i)

wins = [] of Int32
(0...times.size).each do |i|
  wins << (0..times[i]).count do |charge_time|
    (times[i] - charge_time) * charge_time > distances[i]
  end
end

puts "Part 1: #{wins.product}"

big = times.map(&.to_s).join.to_i64
big_record = distances.map(&.to_s).join.to_i64
big_wins = (0..big).count do |charge_time|
  (big - charge_time) * charge_time > big_record
end

puts "Part 2: #{big_wins}"
