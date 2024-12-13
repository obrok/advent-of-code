import kotlin.streams.toList

fun main() {
    val testInput = parseInput(readInput("Day12_test"))
    val input = parseInput(readInput("Day12"))

    println("Part 1 test: ${part1(testInput)}")
    println("Part 1: ${part1(input)}")
    println("Part 2 test: ${part2(testInput)}")
    println("Part 2: ${part2(input)}")
}

private fun part2(input: Map<Position, Char>): Long {
    val visited = emptySet<Position>().toMutableSet()
    val max = input.keys.max()

    val items = sequence {
        for (i in 0..max.x) {
            for (j in 0..max.y) {
                val start = Position(i, j)

                if (!visited.contains(start)) {
                    val (region, perimeter) = explore(input, start)
                    visited.addAll(region)

                    val perimeter2 = perimeter.toMutableSet()
                    var res = 0
                    while (perimeter2.isNotEmpty()) {
                        res += 1

                        val (next, dir) = perimeter2.first()
                        var it = next
                        while (Pair(it, dir) in perimeter2) {
                            perimeter2.remove(Pair(it, dir))
                            it = it.add(dir.turnRight())
                        }

                        it = next.add(dir.turnLeft())
                        while (Pair(it, dir) in perimeter2) {
                            perimeter2.remove(Pair(it, dir))
                            it = it.add(dir.turnLeft())
                        }
                    }

                    yield(region.size.toLong() * res)
                }
            }
        }
    }

    return items.sum()
}

private fun part1(input: Map<Position, Char>): Long {
    val visited = emptySet<Position>().toMutableSet()
    val max = input.keys.max()

    val items = sequence {
        for (i in 0..max.x) {
            for (j in 0..max.y) {
                val start = Position(i, j)
                if (!visited.contains(start)) {
                    val (region, perimeter) = explore(input, start)
                    visited.addAll(region)
                    yield(region.size.toLong() * perimeter.size)
                }
            }
        }
    }

    return items.sum()
}

private fun explore(input: Map<Position, Char>, start: Position): Pair<Set<Position>, Set<Pair<Position, Position>>> {
    val queue = ArrayDeque(listOf(start))
    val region = emptySet<Position>().toMutableSet()
    val plant = input[start]!!
    val perimeter = emptySet<Pair<Position, Position>>().toMutableSet()

    while (queue.isNotEmpty()) {
        val next = queue.removeFirst()
        if (region.contains(next)) {
            continue
        }
        region.add(next)

        for (n in next.neighbours()) {
            if (input[n] == plant) {
                if (!region.contains(n)) {
                    queue.addLast(n)
                }
            } else {
                perimeter.add(Pair(n, n.sub(next)))
            }
        }
    }

    return Pair(region, perimeter)
}

private fun parseInput(input: List<String>): Map<Position, Char> {
    return sequence {
        for (i in input.indices) {
            for (j in input[0].indices) {
                yield(Pair(Position(i, j), input[i][j]))
            }
        }
    }.toMap()
}