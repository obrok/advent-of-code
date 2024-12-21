import kotlin.io.path.Path
import kotlin.io.path.readText

data class Computer(val startingRegisters: Triple<Long, Long, Long>, val instructions: List<Long>)

fun main() {
    val testInput = parseInput(Path("src/Day17_test.txt").readText())
    val input = parseInput(Path("src/Day17.txt").readText())

    println("Part 1 test: ${part1(testInput).joinToString(",")}")
    println("Part 1: ${part1(input).joinToString(",")}")
    println("Part 2: ${part2(input)}")
}

private fun part2(input: Computer): Long {
    var possibleA = setOf(0L)
    for (t in input.instructions.reversed()) {
        possibleA = sequence {
            for (a in possibleA) {
                yieldAll(possibleDigits(input, a, t).map { a * 8 + it })
            }
        }.toSet()
    }

    return possibleA.min()
}

private fun possibleDigits(input: Computer, a: Long, nextOutput: Long): Sequence<Long> {
    return sequence {
        for (d in 0L..7L) {
            val res = part1(input.copy(startingRegisters = input.startingRegisters.copy(first = a * 8 + d)))
            if (res.first() == nextOutput) {
                yield(d)
            }
        }
    }
}

private fun part1(input: Computer): Sequence<Long> {
    return sequence {
        var (a, b, c) = input.startingRegisters
        var ip = 0

        while (ip < input.instructions.size) {
            val op = input.instructions[ip + 1]

            when (input.instructions[ip]) {
                0L -> a /= pow(2, combo(op, a, b, c))
                1L -> b = b.xor(op)
                2L -> b = combo(op, a, b, c) % 8
                3L -> {
                    if (a != 0L) {
                        ip = op.toInt()
                        continue
                    }
                }
                4L -> b = b.xor(c)
                5L -> yield(combo(op, a, b, c) % 8)
                6L -> b = a / pow(2, combo(op, a, b, c))
                7L -> c = a / pow(2, combo(op, a, b, c))
            }

            ip += 2
        }
    }
}

private fun pow(a: Long, b: Long): Long {
    return when (b) {
        0L -> 1L
        1L -> a
        else  -> {
            val res = pow(a, b / 2)

            if (b % 2 == 0L) {
                res * res
            } else {
                res * res * a
            }
        }
    }
}

private fun combo(op: Long, a: Long, b: Long, c: Long): Long {
    return when (op) {
        0L -> 0
        1L -> 1
        2L -> 2
        3L -> 3
        4L -> a
        5L -> b
        6L -> c
        else -> throw Exception("Should not happen")
    }
}

private fun parseInput(input: String): Computer {
    val (registers, instructions) = input.trim().split("\n\n")
    val (a, b, c) = registers.split("\n").map { it.split(": ")[1].toLong() }
    return Computer(Triple(a, b, c), instructions.split(": ")[1].split(",").map { it.toLong() })
}

