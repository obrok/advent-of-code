data class File(val pos: Int, val id: Int, val size: Int)
data class Hole(val pos: Int, val size: Int)

fun main() {
    val testInput = readInput("Day09_test")[0]
    val input = readInput("Day09")[0]

    println("Part 1 test: ${part1(parseInput(testInput))}")
    println("Part 1: ${part1(parseInput(input))}")
    println("Part 2 test: ${part2(parseInput2(testInput))}")
    println("Part 2: ${part2(parseInput2(input))}")
}

private fun part2(input: Pair<List<File>, List<Hole>>): Long {
    val files = input.first
    val holes = input.second.toMutableList()

    return sequence {
        for (f in files.reversed()) {
            val holeIndex = holes.indices.find { holes[it].size >= f.size }

            if (holeIndex != null && holeIndex < f.id) {
                val hole = holes[holeIndex]
                holes[holeIndex] = Hole(pos = hole.pos + f.size, size = hole.size - f.size)
                yield(f.copy(pos = hole.pos))
            } else {
                yield(f)
            }
        }
    }.sumOf {
        it.id.toLong() * (it.pos + (it.pos + it.size - 1)) * it.size / 2
    }
}

private fun part1(input: List<Int?>): Long {
    var end = input.size - 1
    var start = 0

    val positions = sequence {
        while (start <= end) {
            val x = input[start]
            val y = input[end]

            if (x != null) {
                yield(x)
                start += 1
            } else {
                yield(y!!)
                end -= 1
                start += 1
                while (input[end] == null) {
                    end -= 1
                }
            }
        }
    }.toList()

    return positions.indices.sumOf { it.toLong() * positions[it] }
}

private fun parseInput(input: String): List<Int?> {
    val res = emptyList<Int?>().toMutableList()
    var empty = false
    var id = 0
    for (d in input) {
        for (i in 0..<d.toString().toInt()) {
            if (empty) {
                res.add(null)
            } else {
                res.add(id)
            }
        }

        if (!empty) {
            id += 1
        }
        empty = !empty
    }

    return res
}

private fun parseInput2(input: String): Pair<List<File>, List<Hole>> {
    val files = emptyList<File>().toMutableList()
    val holes = emptyList<Hole>().toMutableList()
    var empty = false
    var id = 0
    var pos = 0

    for (i in input.indices) {
        val span = input[i].toString().toInt()
        if (empty) {
            holes.add(Hole(pos, span))
        } else {
            files.add(File(pos, id, span))
            id += 1
        }

        empty = !empty
        pos += span
    }

    return Pair(files, holes)
}