input = STDIN.gets_to_end.chomp
hands = input.split("\n").map do |line|
  hand, bid = line.split(" ")
  hand = hand.split(//).map do |card|
    case card
    when "A"
      14
    when "K"
      13
    when "Q"
      12
    when "J"
      11
    when "T"
      10
    else
      card.to_i
    end
  end
  bid = bid.to_i64

  {hand, bid}
end

puts "Part 1: #{winnings(hands)}"

joker_hands = hands.map do |(hand, bid)|
  hand = hand.map { |card| card == 11 ? 0 : card }
  {hand, bid}
end

puts "Part 2: #{winnings(joker_hands)}"

def winnings(hands)
  hands.sort_by do |(hand, _)|
    {rank(hand), hand}
  end.each_with_index.map do |((_, bid), index)|
    bid * (index + 1)
  end.sum
end

def rank(hand)
  groups = hand.group_by { |card| card }
  jokers = groups.has_key?(0) ? groups[0].size : 0

  return 7 if jokers == 5

  groups.delete(0)
  groups = groups.values.sort_by { |group| -group.size }.map(&.size)
  groups[0] += jokers

  if groups[0] == 5
    7
  elsif groups[0] == 4
    6
  elsif groups[0] == 3 && groups[1] == 2
    5
  elsif groups[0] == 3
    4
  elsif groups[0] == 2 && groups[1] == 2
    3
  elsif groups[0] == 2
    2
  else
    1
  end
end
