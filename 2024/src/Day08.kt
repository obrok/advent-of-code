data class Antennas(val antennas: Map<Char, List<Position>>, val bounds: Bounds)

fun main() {
    val testInput = parseInput(readInput("Day08_test"))
    val input = parseInput(readInput("Day08"))

    println("Part 1 test: ${part1(testInput)}")
    println("Part 1: ${part1(input)}")
    println("Part 2 test: ${part2(testInput)}")
    println("Part 2: ${part2(input)}")
}

private fun part1(input: Antennas): Int {
    return sequence {
        for (ants in input.antennas.values) {
            for (a in ants) {
                for (b in ants) {
                    if (a != b) {
                        val dir = b.sub(a)
                        val pos1 = b.add(dir)
                        val pos2 = a.add(dir.neg())

                        if (input.bounds.contains(pos1)) {
                            yield(pos1)
                        }

                        if (input.bounds.contains(pos2)) {
                            yield(pos2)
                        }
                    }
                }
            }
        }
    }.toSet().count()
}

private fun part2(input: Antennas): Int {
    return sequence {
        for (ants in input.antennas.values) {
            for (a in ants) {
                for (b in ants) {
                    if (a != b) {
                        val dir = b.sub(a)
                        var temp = b
                        while (input.bounds.contains(temp)) {
                            yield(temp)
                            temp = temp.add(dir)
                        }

                        temp = a
                        while(input.bounds.contains(temp)) {
                            yield(temp)
                            temp = temp.add(dir.neg())
                        }
                    }
                }
            }
        }
    }.toSet().count()
}

private fun parseInput(input: List<String>): Antennas {
    val antennas = sequence {
        for (i in input.indices) {
            for (j in input[i].indices) {
                if (input[i][j] != '.') {
                    yield(Position(i, j))
                }
            }
        }
    }.groupBy { (i, j) -> input[i][j] }

    return Antennas(antennas, Bounds(Position(0, 0), Position(input.size, input[0].length)))
}