input = STDIN.gets_to_end.chomp

steps = input.split("\n")[0].split(",")
hashes = steps.map { |x| hash(x) }

puts "Part 1: #{hashes.sum}"

boxes = (0...256).map { |x| [] of {String, Int32} }
steps.each do |step|
  if step.ends_with?("-")
    label = step[0...-1]
    boxes[hash(label)].reject! { |x| x[0] == label }
  else
    label, value = step.split("=")
    value = value.to_i32
    box = boxes[hash(label)]
    existing = box.index { |x| x[0] == label }

    if existing
      box[existing] = {label, value}
    else
      box << {label, value}
    end
  end
end

total = boxes.each_with_index.flat_map do |box, i|
  box.each_with_index.map do |(_, value), j|
    (i + 1) * (j + 1) * value
  end
end.sum

puts "Part 2: #{total}"

def hash(step)
  step.bytes.map { |x| x.to_i32 }.reduce(0) do |acc, x|
    (acc + x) * 17 % 256
  end
end
