import kotlin.math.pow

data class Equation(val result: Long, val operands: List<Long>)

fun main() {
    val testInput = parseInput(readInput("Day07_test"))
    val input = parseInput(readInput("Day07"))

    println("Part 1 test: ${part1(testInput)}")
    println("Part 1: ${part1(input)}")
    println("Part 2 test: ${part2(testInput)}")
    println("Part 2: ${part2(input)}")
}

private fun part1(input: List<Equation>): Long {
    return input.filter { equation ->
        interpretations(equation.operands).any { it == equation.result }
    }.sumOf { it.result }
}

private fun part2(input: List<Equation>): Long {
    return input.filter { equation ->
        part2Interpretations(equation.operands).any { it == equation.result }
    }.sumOf { it.result }
}

private fun part2Interpretations(operands: List<Long>): Sequence<Long> {
    val maxMask = (3.0).pow(operands.count() - 1).toInt()

    return sequence {
        for (mask in 0..<maxMask) {
            var tempMask = mask
            var res = operands[0]

            for (i in 1..<operands.count()) {
                val op = tempMask % 3
                tempMask /= 3

                when (op) {
                    0 -> {
                        res += operands[i]
                    }
                    1 -> {
                        res *= operands[i]
                    }
                    else -> {
                        res = "$res${operands[i]}".toLong()
                    }
                }
            }

            yield(res)
        }
    }
}

private fun interpretations(operands: List<Long>): Sequence<Long> {
    return sequence {
        val maskLength = operands.count() - 1
        val maxMask = (2.0).pow(maskLength).toInt()

        for (mask in 0..<maxMask) {
            var res = operands[0]
            for (i in 1..<operands.count()) {
                if ((mask shr (i - 1)) % 2 == 0) {
                    res += operands[i]
                } else {
                    res *= operands[i]
                }
            }

            yield(res)
        }
    }
}

private fun parseInput(input: List<String>): List<Equation> {
    return input.map { line ->
        val (result, operands) = line.split(": ")
        Equation(result.toLong(), operands.split(" ").map { it.toLong() })
    }
}