import kotlin.math.abs

fun main() {
    print("Part1 test: ")
    println(part1(parseInput(readInput("Day02_test"))))
    print("Part1: ")
    println(part1(parseInput(readInput("Day02"))))
    print("Part2 test: ")
    println(part2(parseInput(readInput("Day02_test"))))
    print("Part2: ")
    println(part2(parseInput(readInput("Day02"))))
}

fun part1(input: List<List<Int>>): Int {
    return input.count { validReport(it) }
}

fun validReport(report: List<Int>): Boolean {
    val pairs = report.zip(report.drop(1))
    val directions = pairs.map { (a, b) -> a >= b }.groupBy { it }.count() == 1
    val sizes = pairs.all { (a, b) -> abs(a - b) in 1..3 }
    return directions && sizes
}

fun part2(input: List<List<Int>>): Int {
    return input.count { report ->
        validReport(report) || skipReports(report).any { validReport(it) }
    }
}

fun skipReports(report: List<Int>): List<List<Int>> {
    return report.indices.map { i ->
        val res = report.toMutableList()
        res.removeAt(i)
        res
    }
}

private fun parseInput(input: List<String>): List<List<Int>> {
    return input.map { it.split(" ").map { x -> x.toInt() } }
}