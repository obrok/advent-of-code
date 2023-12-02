games = STDIN.gets_to_end.chomp.split('\n').map do |line|
  game, rest = line.split(':')
  _, game_id = game.split
  shows = rest.split(";").map do |show|
    show.split(',').map do |balls|
      count, color = balls.strip.split
      {color, count.to_i}
    end || [] of {String, Int32}
  end
  {game_id.to_i, shows}
end

max = {
  "red"   => 12,
  "green" => 13,
  "blue"  => 14,
}

possible = games.select do |(game_id, shows)|
  shows.all? do |show|
    show.all? do |(color, count)|
      count <= max[color]
    end
  end
end

puts("Part 1: #{possible.map { |game_id, _| game_id }.sum}")

powers = games.map do |(game_id, shows)|
  min = {
    "red"   => 0,
    "green" => 0,
    "blue"  => 0,
  }

  shows.each do |show|
    show.each do |(color, count)|
      min[color] = [count, min[color]].max
    end
  end

  min.values.product
end

puts("Part 2: #{powers.sum}")
