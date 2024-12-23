import kotlin.io.path.Path
import kotlin.io.path.readText

data class Towels(val available: List<String>, val patterns: List<String>)

fun main() {
    val testInput = parseInput(Path("src/Day19_test.txt").readText())
    val input = parseInput(Path("src/Day19.txt").readText())

    println("Part 1 test: ${part1(testInput)}")
    println("Part 1: ${part1(input)}")
    println("Part 2 test: ${part2(testInput)}")
    println("Part 2: ${part2(input)}")
}

private fun part1(input: Towels): Int {
    return input.patterns.count { ways(it, input.available) > 0 }
}

private fun part2(input: Towels): Long {
    return input.patterns.sumOf { ways(it, input.available) }
}

private fun ways(pattern: String, available: List<String>): Long {
    val memo = emptyMap<Int, Long>().toMutableMap()

    fun inner(index: Int): Long {
        if (index == pattern.length) {
            return 1
        }

        if (memo[index] == null) {
            memo[index] = available.filter {
                pattern.startsWith(it, index)
            }.sumOf {  inner(index + it.length) }
        }

        return memo[index]!!
    }

    return inner(0)
}

private fun parseInput(input: String): Towels {
    val (available, patterns) = input.trim().split("\n\n")
    return Towels(available.split(", "), patterns.split("\n"))
}