import kotlin.io.path.Path
import kotlin.io.path.readText

fun main() {
    val input = parseInput(Path("src/Day25.txt").readText())

    val fit = sequence {
        for (k in input.first) {
            for (l in input.second) {
                yield(Pair(k, l))
            }
        }
    }.count { (key, lock) ->
        key.zip(lock).none { (x, y) ->
            x + y >= 6
        }
    }

    println("Part 1: $fit")
}

private fun parseInput(input: String): Pair<List<List<Int>>, List<List<Int>>> {
    val keys = mutableListOf<List<Int>>()
    val locks = mutableListOf<List<Int>>()

    for (schematic in input.trim().split("\n\n")) {
        val lines = schematic.split("\n")
        val pattern = (0..<5).map { i ->
            lines.count { it[i] == '#' } - 1
        }
        if (lines[0][0] == '#') {
            locks.add(pattern)
        } else {
            keys.add(pattern)
        }
    }

    return Pair(keys, locks)
}
