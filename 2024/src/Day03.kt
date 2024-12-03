fun main() {
    val testInput1 = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"
    val testInput2 = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"
    val input = readInput("Day03").joinToString("\n")

    println("Part1 test: ${part1(testInput1)}")
    println("Part1: ${part1(input)}")
    println("Part2 test: ${part2(testInput2)}")
    println("Part2: ${part2(input)}")
}

fun part1(input: String): Int {
    return Regex("""mul\((\d+),(\d+)\)""").findAll(input).map {
        val (x, y) = it.destructured
        x.toInt() * y.toInt()
    }.sum()
}

fun part2(input: String): Int {
    var enabled = 1
    return Regex("""mul\((\d+),(\d+)\)|do\(\)|don't\(\)""").findAll(input).map {
        when (it.value) {
            "do()" -> {
                enabled = 1
                0
            }

            "don't()" -> {
                enabled = 0
                0
            }

            else -> {
                val (x, y) = it.destructured
                x.toInt() * y.toInt() * enabled
            }
        }
    }.sum()
}
