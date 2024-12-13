import kotlin.math.abs

data class Machine(val buttonA: Position, val buttonB: Position, val prize: Position)

fun main() {
    val testInput = parseInput(readInput("Day13_test"))
    val input = parseInput(readInput("Day13"))

    println("Part 1 test: ${part1(testInput)}")
    println("Part 1: ${part1(input)}")
    println("Part 2 test: ${part2(testInput)}")
    println("Part 2: ${part2(input)}")
}

private fun part2(input: List<Machine>): Long {
    return input.sumOf { machine ->
        val targetX = machine.prize.x.toLong() + 10000000000000
        val targetY = machine.prize.y.toLong() + 10000000000000
        val targetDif = targetX - targetY
        val aXDif = machine.buttonA.x - machine.buttonA.y

        var lo = 0L
        var hi = 10000000000000
        while (hi - lo > 1) {
            val mid = (hi + lo) / 2
            val bs = (targetX - mid * machine.buttonA.x) / machine.buttonB.x
            val x = mid * machine.buttonA.x + bs * machine.buttonB.x
            val y = mid * machine.buttonA.y + bs * machine.buttonB.y
            val diff = x - y

            if ((diff > targetDif) && (aXDif > 0)) {
                hi = mid
            } else if ((diff < targetDif) && (aXDif < 0)) {
                hi = mid
            } else {
                lo = mid
            }
        }

        val bs = (targetX - lo * machine.buttonA.x) / machine.buttonB.x
        val x = lo * machine.buttonA.x + bs * machine.buttonB.x
        val y = lo * machine.buttonA.y + bs * machine.buttonB.y

        if (x == targetX && y == targetY) {
            3 * lo + bs
        } else {
            0L
        }
    }
}

private fun part1(input: List<Machine>): Long {
    return input.sumOf { machine ->
        sequence {
            for (da in 0..100) {
                for (db in 0..100) {
                    val x = da * machine.buttonA.x + db * machine.buttonB.x
                    val y = da * machine.buttonA.y + db * machine.buttonB.y

                    if (Position(x, y) == machine.prize) {
                        yield(3 * da.toLong() + db)
                    }
                }
            }
        }.minOrNull() ?: 0
    }
}


private fun parseInput(input: List<String>): List<Machine> {
    return input.chunked(4).map {
        val button = Regex("""X\+(\d+), Y\+(\d+)""")
        val xa = button.find(it[0])!!.groups[1]!!.value.toInt()
        val ya = button.find(it[0])!!.groups[2]!!.value.toInt()
        val xb = button.find(it[1])!!.groups[1]!!.value.toInt()
        val yb = button.find(it[1])!!.groups[2]!!.value.toInt()

        val prize = Regex("""X=(\d+), Y=(\d+)""")
        val prizeA = prize.find(it[2])!!.groups[1]!!.value.toInt()
        val prizeB = prize.find(it[2])!!.groups[2]!!.value.toInt()

        Machine(Position(xa, ya), Position(xb, yb), Position(prizeA, prizeB))
    }
}