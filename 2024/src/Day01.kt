import kotlin.math.abs

fun main() {
    fun part1(input: List<String>): Int {
        val (list1, list2) = input.map { line -> line.split(Regex("""\W+""")).map { it.toInt() } }.map { Pair(it[0], it[1])}.unzip()
        return list1.sorted().zip(list2.sorted()).sumOf { (x, y) -> abs(x - y) }
    }

    fun part2(input: List<String>): Int {
        val (list1, list2) = input.map { line -> line.split(Regex("""\W+""")).map { it.toInt() } }.map { Pair(it[0], it[1])}.unzip()
        val counts = list2.groupBy { it }.toMap()
        return list1.sumOf { it * (counts[it]?.count() ?: 0) }
    }

    val testInput = readInput("Day01_test")
    val input = readInput("Day01")

    print("Part1 test: ")
    part1(testInput).println()
    print("Part1: ")
    part1(input).println()

    print("Part2 test: ")
    part2(testInput).println()
    print("Part2: ")
    part2(input).println()

}
