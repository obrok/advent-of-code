fun main() {
    val testInput = parseInput(readInput("Day14_test"))
    val input = parseInput(readInput("Day14"))

    println("Part 1 test: ${part1(testInput)}")
    println("Part 1: ${part1(input)}")
    println("Part 2: ${part2(input)}")
}

const val sizeX = 101
const val sizeY = 103
const val time = 100

private fun part1(input: List<Pair<Position, Position>>): Long {
    return input.groupBy { robot ->
        val (finalX, finalY) = simulate(robot, time)
        Pair(finalX.compareTo(sizeX / 2), finalY.compareTo(sizeY / 2))
    }.filter { (k, _) -> k.first != 0 && k.second != 0 }.values.map { it.size.toLong() }
        .reduce { x, y -> x * y }
}

private fun simulate(robot: Pair<Position, Position>, t: Int): Position {
    val (pos, vel) = robot
    var finalX = (pos.x + vel.x * t) % sizeX
    if (finalX < 0) {
        finalX += sizeX
    }
    var finalY = (pos.y + vel.y * t) % sizeY
    if (finalY < 0) {
        finalY += sizeY
    }

    return Position(finalX, finalY)
}

private fun part2(input: List<Pair<Position, Position>>): Int {
    return (0..(sizeX * sizeY)).maxBy { time ->
        val robots = input.map { simulate(it, time) }.toSet()
        robots.sumOf { robot ->
            robot.neighbours().count { robots.contains(it) }
        }
    }
}

private fun parseInput(input: List<String>): List<Pair<Position, Position>> {
    val robot = Regex("""p=(.+),(.+) v=(.+),(.+)""")
    return input.map { line ->
        val match = robot.find(line)!!.groupValues
        Pair(Position(match[1].toInt(), match[2].toInt()), Position(match[3].toInt(), match[4].toInt()))
    }
}