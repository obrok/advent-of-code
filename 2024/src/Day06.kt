import kotlin.math.abs
import kotlin.math.absoluteValue

data class Position(val x: Int, val y: Int): Comparable<Position> {
    fun add(dir: Position): Position {
        return Position(x + dir.x, y + dir.y)
    }

    fun turnRight(): Position {
        return Position(y, -x)
    }

    fun turnLeft(): Position {
        return Position(-y, x)
    }

    fun sub(other: Position): Position {
        return Position(x - other.x, y - other.y)
    }

    fun neg(): Position {
        return Position(-x, -y)
    }

    fun taxi(other: Position): Int {
        return abs(x - other.x) + abs(y - other.y)
    }

    override fun compareTo(other: Position): Int {
        val res1 = x.compareTo(other.x)

        return if (res1 == 0) {
            y.compareTo(other.y)
        } else {
            res1
        }
    }

    fun neighbours(): Sequence<Position> {
        return sequence {
            yield(Position(x + 1, y))
            yield(Position(x - 1, y))
            yield(Position(x, y + 1))
            yield(Position(x, y - 1))
        }
    }

    fun abs(): Position {
        return Position(x.absoluteValue, y.absoluteValue)
    }

    fun mul(other: Position): Position {
        return Position(x * other.x, y * other.y)
    }

    fun flip(): Position {
        return Position(y, x)
    }
}

data class Bounds(val lo: Position, val hi: Position) {
    fun contains(position: Position): Boolean {
        return position.x in (lo.x..<hi.x) &&
                position.y in (lo.y..<hi.y)
    }
}

data class PatrolMap(val start: Position, val obstacles: Set<Position>, val bounds: Bounds)

fun main() {
    val testInput = parseInput(readInput("Day06_test"))
    val input = parseInput(readInput("Day06"))

    println("Part 1 test: ${part1(testInput)}")
    println("Part 1: ${part1(input)}")
    println("Part 2 test: ${part2(testInput)}")
    println("Part 2: ${part2(input)}")
}

private fun part2(input: PatrolMap): Int {
    var loops = 0

    for (i in input.bounds.lo.x..<input.bounds.hi.x) {
        for (j in input.bounds.lo.y..<input.bounds.hi.y) {
            val obstacles = input.obstacles.union(listOf(Position(i, j)))
            val visited = emptySet<Pair<Position, Position>>().toMutableSet()
            var pos = input.start
            var dir = Position(-1, 0)

            while (input.bounds.contains(pos)) {
                if (visited.contains(Pair(pos, dir))) {
                    loops += 1
                    break
                }

                visited.add(Pair(pos, dir))
                val newPos = pos.add(dir)

                if (obstacles.contains(newPos)) {
                    dir = dir.turnRight()
                } else {
                    pos = newPos
                }
            }
        }
    }

    return loops
}

private fun part1(input: PatrolMap): Int {
    var pos = input.start
    var dir = Position(-1, 0)
    val visited = emptySet<Position>().toMutableSet()

    while (input.bounds.contains(pos)) {
        visited.add(pos)
        val newPos = pos.add(dir)

        if (input.obstacles.contains(newPos)) {
            dir = dir.turnRight()
        } else {
            pos = newPos
        }
    }

    return visited.count()
}

private fun parseInput(input: List<String>): PatrolMap {
    val bounds = Bounds(
        Position(0, 0),
        Position(input[0].length, input.count())
    )
    var start = Position(0, 0)
    val obstacles = emptySet<Position>().toMutableSet()

    for (i in input.indices) {
        for (j in input[i].indices) {
            if (input[i][j] == '^') {
                start = Position(i, j)
            }

            if (input[i][j] == '#') {
                obstacles.add(Position(i, j))
            }
        }
    }

    return PatrolMap(start, obstacles, bounds)
}