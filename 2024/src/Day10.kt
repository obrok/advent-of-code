fun main() {
    val testInput = parseInput(readInput("Day10_test"))
    val input = parseInput(readInput("Day10"))

    println("Part 1 test: ${part1(testInput)}")
    println("Part 1: ${part1(input)}")
    println("Part 2 test: ${part2(testInput)}")
    println("Part 2: ${part2(input)}")
}

private fun part1(input: List<List<Int>>): Int {
    return input.indices.sumOf { x ->
        input[x].indices.sumOf { y ->
            reachable(input, x, y, 0).size
        }
    }
}

private fun part2(input: List<List<Int>>): Int {
    return input.indices.sumOf { x ->
        input[x].indices.sumOf { y ->
            score(input, x, y, 0)
        }
    }
}

private fun score(input: List<List<Int>>, x: Int, y: Int, height: Int): Int {
    if (x !in input.indices || y !in input[0].indices || input[x][y] != height) {
        return 0
    }

    if (height == 9) {
        return 1
    }

    return score(input, x + 1, y, height + 1) + score(input, x, y + 1, height + 1) +
        score(input, x - 1, y, height + 1) + score(input, x, y - 1, height + 1)
}

private fun reachable(input: List<List<Int>>, x: Int, y: Int, height: Int): Set<Position> {
    if (x !in input.indices || y !in input[0].indices || input[x][y] != height) {
        return emptySet()
    }

    if (height == 9) {
        return setOf(Position(x, y))
    }

    return reachable(input, x + 1, y, height + 1).union(reachable(input, x, y + 1, height + 1))
        .union(reachable(input, x - 1, y, height + 1)).union(reachable(input, x, y - 1, height + 1))
}

private fun parseInput(input: List<String>): List<List<Int>> {
    return input.map { row ->
        row.map {
            it.toString().toInt()
        }
    }
}