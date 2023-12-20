input = STDIN.gets_to_end.strip.chomp

alias Condition = {Char | Nil, Char | Nil, Int64 | Nil}

workflows, items = input.split("\n\n")

workflows = workflows.split("\n").map do |line|
  name, rest = line.split("{")
  rest = rest.strip("}").split(",").map do |condition|
    if condition.size < 2 || (condition[1] != '<' && condition[1] != '>')
      {nil, nil, nil, condition}
    else
      condition, target = condition.split(":")
      attr = condition[0]
      eq = condition[1]
      value = condition[2..].to_i64

      {attr, eq, value, target}
    end
  end

  {name, rest}
end.to_h

items = items.split("\n").map do |line|
  item = {} of Char => Int64
  line.strip("{}").split(",").map do |attr|
    item[attr[0]] = attr[2..].to_i64
  end
  item
end

part1 = items.select { |item| simulation(item, "in", workflows) == "A" }.map { |item| item.values.sum }.sum
puts "Part 1: #{part1}"

conditions = traverse("in", workflows, [] of Condition).map { |c| to_cube(c) }
puts "Part 2: #{conditions.map { |x| cube_size(x) }.sum}"

def cube_size(cube)
  ['x', 'm', 'a', 's'].map do |dim|
    a, b = cube[dim]
    return 0i64 if b < a
    b - a + 1
  end.product
end

def to_cube(conditions)
  bounds = {
    'x' => {1i64, 4000i64},
    'm' => {1i64, 4000i64},
    'a' => {1i64, 4000i64},
    's' => {1i64, 4000i64},
  }

  conditions.select { |c| c[0] }.each do |(dim, sign, value)|
    lo, hi = bounds[dim.not_nil!]
    if sign == '<'
      hi = [hi, value.not_nil! - 1].min.not_nil!
    else
      lo = [lo, value.not_nil! + 1].max.not_nil!
    end
    bounds[dim.not_nil!] = {lo, hi}
  end

  bounds
end

def traverse(name, workflows, conditions) : Array(Array(Condition))
  if name == "A"
    [conditions]
  elsif name == "R"
    [] of Array(Condition)
  else
    total = 0i64
    workflows[name].flat_map do |flow|
      a, b, c, to = flow
      res = traverse(to, workflows, conditions + [{a, b, c}])
      conditions = conditions + [neg({a, b, c})]
      res
    end.to_a
  end
end

def neg(cond) : Condition
  a, b, c = cond
  case b
  when '<' then {a, '>', c.not_nil! - 1}
  when '>' then {a, '<', c.not_nil! + 1}
  when nil then {nil, nil, nil}
  else          raise "Should not happen"
  end
end

def simulation(item, name, workflows)
  if ["A", "R"].includes?(name)
    return name
  end

  workflows[name].each do |flow|
    if matches?(item, {flow[0], flow[1], flow[2]})
      return simulation(item, flow[3], workflows)
    end
  end

  "R"
end

def matches?(item, condition : {Char | Nil, Char | Nil, Int64 | Nil})
  !condition[0] ||
    (condition[1] == '<' && item[condition[0]] < condition[2].not_nil!) ||
    (condition[1] == '>' && item[condition[0]] > condition[2].not_nil!)
end
