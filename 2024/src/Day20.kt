import kotlin.math.abs

data class Track(val walls: Set<Position>, val start: Position, val end: Position)
data class Cheat(val start: Position, val end: Position, val size: Int)

fun main() {
    val testInput = parseInput(readInput("Day20_test"))
    val input = parseInput(readInput("Day20"))

    println("Part 1 test: ${part1(testInput)}")
    println("Part 1: ${part1(input)}")
    println("Part 2 test: ${part2(testInput)}")
    println("Part 2: ${part2(input)}")
}

private fun part1(input: Track): Int {
    return cheats(input, 2).count { it.size >= 100 }
}

private fun part2(input: Track): Int {
    return cheats(input, 20).count { it.size >= 100}
}

private fun cheats(input: Track, maxCheatLen: Int): Set<Cheat> {
    val distances = emptyMap<Position, Int>().toMutableMap()
    var dist = 0
    var curr: Position? = input.start

    while (curr != null) {
        distances[curr] = dist
        dist += 1
        curr = curr.neighbours().find { distances[it] == null && !input.walls.contains(it) }
    }

    return sequence {
        for (it in distances.keys) {
            for (other in distances.keys) {
                if (it.taxi(other) <= maxCheatLen) {
                    val size = distances[other]!! - distances[it]!! - it.taxi(other)
                    if (size > 0) {
                        yield(Cheat(it, other, size))
                    }
                }
            }
        }
    }.toSet()
}

private fun parseInput(input: List<String>): Track {
    var start = Position(0, 0)
    var end = Position(0, 0)
    val walls = emptySet<Position>().toMutableSet()

    for (x in input.indices) {
        for (y in input[x].indices) {
            when (input[x][y]) {
                'S' -> start = Position(x, y)
                'E' -> end = Position(x, y)
                '#' -> walls.add(Position(x, y))
                else -> {}
            }
        }
    }

    return Track(walls, start, end)
}