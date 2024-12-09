import kotlin.io.path.Path
import kotlin.io.path.readText

data class Rules(
    val rules: Set<Pair<Int, Int>>,
    val updates: List<List<Int>>
): Comparator<Int> {
    override fun compare(o1: Int?, o2: Int?): Int {
        if (o1 != null && o2 != null) {
            if (rules.contains(Pair(o1, o2))) {
                return -1
            }

            if (rules.contains(Pair(o2, o1))) {
                return 1
            }
        }

        return 0
    }
}

fun main() {
    val testInput = parseInput(Path("src/Day05_test.txt").readText().trim())
    val input = parseInput(Path("src/Day05.txt").readText().trim())

    println("Part 1 test: ${part1(testInput)}")
    println("Part 1: ${part1(input)}")
    println("Part 2 test: ${part2(testInput)}")
    println("Part 2: ${part2(input)}")
}

fun part1(rules: Rules): Int {
    return rules.updates.filter { update ->
        update.zip(update.drop(1)).all { (a, b) ->
           !rules.rules.contains(Pair(b, a))
        }
    }.sumOf {
        it[it.count() / 2]
    }
}

fun part2(rules: Rules): Int {
    return rules.updates.filter { update ->
        update.zip(update.drop(1)).any { (a, b) ->
            rules.rules.contains(Pair(b, a))
        }
    }.map {
        it.sortedWith(rules)
    }.sumOf {
        it[it.count() / 2]
    }
}

private fun parseInput(text: String): Rules {
    val (rules, updates) = text.split("\n\n")
    return Rules(
        rules = rules.split("\n").map {
            val (a, b) = it.split("|")
            Pair(a.toInt(), b.toInt())
        }.toSet(),
        updates = updates.split("\n").map { it.split(",").map { x -> x.toInt() }}
    )
}