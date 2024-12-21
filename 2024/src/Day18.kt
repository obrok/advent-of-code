import kotlin.collections.ArrayDeque

fun main() {
    val testInput = parseInput(readInput("Day18_test"))
    val input = parseInput(readInput("Day18"))

    println("Part 1 test: ${part1(testInput, 6, 11)}")
    println("Part 1: ${part1(input, 70, 1023)}")
    println("Part 2 test: ${part2(testInput, 6)}")
    println("Part 2: ${part2(input, 70)}")
}

private fun part2(input: List<Position>, size: Int): Position {
    val index = (0..input.size).find {
        part1(input, size, it) == null
    }
    return input[index!!]
}

private fun part1(input: List<Position>, size: Int, noObstacles: Int): Int? {
    val queue = ArrayDeque<Pair<Position, Int>>()
    queue.add(Pair(Position(0, 0), 0))
    val obstacles = input.indices.associateBy { input[it] }
    val visited = emptySet<Position>().toMutableSet()

    while (queue.isNotEmpty()) {
        val (pos, time) = queue.removeFirst()
        if (visited.contains(pos)) {
            continue
        }

        if (pos == Position(size, size)) {
            return time
        }

        visited.add(pos)

        for (n in pos.neighbours()) {
            if (!visited.contains(n) && n.x in 0..size && n.y in 0..size) {
                if ((obstacles[n] ?: Int.MAX_VALUE) > noObstacles) {
                    queue.add(Pair(n, time + 1))
                }
            }
        }
    }

    return null
}

private fun parseInput(input: List<String>): List<Position> {
    return input.map {
        val (x, y) = it.split(",")
        Position(x.toInt(), y.toInt())
    }
}