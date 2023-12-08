require "big"

input = STDIN.gets_to_end.chomp
instructions, map = input.split("\n\n")

map = map.split("\n").map do |line|
  from, to = line.split(" = ")
  left, right = to.strip("(").strip(")").split(", ")

  {from, {left, right}}
end.to_h

i = 0
node = "AAA"
instructions = instructions.split(//)

while node != "ZZZ"
  instruction = instructions[i % instructions.size]
  i += 1

  if instruction == "L"
    node = map[node][0]
  elsif instruction == "R"
    node = map[node][1]
  end
end

puts "Part 1: #{find_node(instructions, map, "AAA") { |node| node == "ZZZ" }}"

nodes = map.keys.select { |node| node =~ /A$/ }
all = nodes.map { |node| find_node(instructions, map, node) { |node| node =~ /Z$/ } }.reduce { |a, b| a.lcm(b) }
puts "Part 2: #{all}"

def find_node(instructions, map, start)
  i = 0
  node = start

  while !yield(node)
    instruction = instructions[i % instructions.size]
    i += 1

    if instruction == "L"
      node = map[node][0]
    else
      node = map[node][1]
    end
  end

  BigInt.new(i)
end
