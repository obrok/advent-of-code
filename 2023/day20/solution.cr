input = STDIN.gets_to_end.strip.chomp

machine = input.split("\n").map do |line|
  name, outputs = line.split(" -> ")
  outputs = outputs.split(", ")

  if name == "broadcaster"
    {"broadcaster", {:broadcaster, outputs}}
  else
    type = name[0] == '%' ? :flip : :conj
    {name[1..], {type, outputs}}
  end
end.to_h

hi = 0i64
lo = 0i64
part1_state = prepare_state(machine)

1000.times do
  queue = [{"button", "broadcaster", false}]

  while !queue.empty?
    from, target, value = queue.pop
    value ? (hi += 1) : (lo += 1)
    signals = handle(machine, part1_state, from, target, value)
    signals.each { |s| queue.push(s) }
  end
end

puts "Part 1: #{lo * hi}"

names = {"broadcaster" => 0}
machine.each do |(_, gate)|
  gate[1].each do |name|
    if !names.has_key?(name)
      names[name] = names.size
    end
  end
end

types = names.to_a.sort_by { |k, v| v }.map { |(k, v)| machine.has_key?(k) ? machine[k][0] : :none }
outputs = names.to_a.sort_by { |k, v| v }.map do |(k, v)|
  machine.has_key?(k) ? machine[k][1].map { |x| names[x] } : [] of Int32
end
inputs = names.to_a.sort_by { |k, v| v }.map do |(k, v)|
  (0...outputs.size).select { |idx| outputs[idx].includes?(v) }
end
state = [false] * names.size

queue = outputs[0].map { |x| {x, 0} }.reverse
parent = [-1] * names.size
visited = [false] * names.size
while !queue.empty?
  node, from = queue.pop
  next if visited[node]
  visited[node] = true

  if types[node] == :flip && types[from] == :flip && !parent.any? { |x| x == from }
    parent[node] = from
  end

  outputs[node].sort_by { |output| types[output] == :flip ? output + 100 : output }
    .each { |output| queue.push({output, node}) }
end
roots = (0...parent.size).map { |i| i if parent[i] == -1 && types[i] == :flip }.compact

numbers =
  roots.map do |i|
    items = [i]
    while i = parent.index { |x| x == i }
      items << i
    end
    items
  end

values = roots.map { |i| {i, 0i64} }.to_h
cycles = roots.map { |i| {i, 0i64} }.to_h

10000.times do |i|
  queue = [{0, false}]

  numbers.each do |bits|
    value = bits.reverse.map { |bit| state[bit] ? '1' : '0' }.join("").to_i64(2)
    if value == 0
      cycles[bits[0]] = values[bits[0]] + 1
    end
    values[bits[0]] = value
  end

  while !queue.empty?
    target, value = queue.pop
    case types[target]
    when :broadcaster
      outputs[target].each { |output| queue.unshift({output, value}) }
    when :flip
      if !value
        state[target] = !state[target]
        outputs[target].each { |output| queue.unshift({output, state[target]}) }
      end
    when :conj
      state[target] = !inputs[target].all? { |input| state[input] }

      outputs[target].each { |output| queue.unshift({output, state[target]}) }
    when :none
      if !value
        puts "Part 2: #{i + 1}"
        break 2
      end
    end
  end
end

cycles.values.reduce { |a, b| a.lcm(b) }.tap { |x| puts "Part 2: #{x}" }

def prepare_state(machine)
  state = {} of String => Hash(String, Bool)

  machine.each do |(k, (type, outputs))|
    if type == :flip
      state[k] = {"" => false}
    end

    outputs.each do |name|
      if machine.has_key?(name) && machine[name][0] == :conj
        state[name] ||= {} of String => Bool
        state[name][k] = false
      end
    end
  end

  state
end

def handle(machine, state, from, target, value)
  if !machine.has_key?(target)
    return [] of {String, String, Bool}
  end

  case machine[target][0]
  when :broadcaster
    return machine[target][1].map { |t| {target, t, value} }
  when :flip
    if value
      return [] of {String, String, Bool}
    else
      state[target][""] = !state[target][""]
      return machine[target][1].map { |t| {target, t, state[target][""]} }
    end
  when :conj
    state[target][from] = value
    value = !state[target].values.all?
    return machine[target][1].map { |t| {target, t, value} }
  else
    raise "Should not happen"
  end
end
