input = STDIN.gets_to_end.strip.chomp

initial_edges = [] of {String, String}

input.split("\n").each do |line|
  left, right = line.split(": ")
  right = right.split(" ")
  right.each do |r|
    initial_edges << {left, r}
  end
end

while true
  edges = initial_edges
  edges = fast_mincut(edges)

  if edges.size == 3
    node1, node2 = nodes(edges)
    puts "Part 1: #{(node1.size // 3) * (node2.size // 3)}"

    break
  end
end

def fast_mincut(edges)
  if nodes(edges).size <= 6
    return contract(edges, 2)
  else
    t = 1 + nodes(edges).size * 10 // 14
    g1 = fast_mincut(contract(edges, t))
    if g1.size == 3
      return g1
    end
    g2 = fast_mincut(contract(edges, t))
    return g1.size < g2.size ? g1 : g2
  end
end

def node_count(edges)
  nodes(edges).size
end

def nodes(edges)
  edges.flat_map { |e| [e[0], e[1]] }.uniq
end

def contract(edges, to)
  while nodes(edges).size > to
    to_contract = edges.sample
    new_node = to_contract[0] + to_contract[1]
    edges = edges.reject { |e| to_contract.includes?(e[0]) && to_contract.includes?(e[1]) }.map do |e|
      e.map { |n| n == to_contract[0] || n == to_contract[1] ? new_node : n }
    end
  end

  edges
end
