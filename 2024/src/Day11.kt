fun main() {
    val testInput = readInput("Day11_test")[0].split(" ").map { it.toLong() }
    val input = readInput("Day11")[0].split(" ").map { it.toLong() }

    println("Part 1 test: ${part1(testInput)}")
    println("Part 1: ${part1(input)}")
    println("Part 2 test: ${part2(testInput)}")
    println("Part 2: ${part2(input)}")
}

private fun part1(stones: List<Long>): Long {
    return stones.map { sim(it, 25) }.sum()
}

private fun part2(stones: List<Long>): Long {
    return stones.map { sim(it, 75) }.sum()
}

private val memo: MutableMap<Pair<Long, Int>, Long> = emptyMap<Pair<Long, Int>, Long>().toMutableMap()

private fun sim(stone: Long, iterations: Int): Long {
    val key = Pair(stone, iterations)
    val memoized = memo[key]
    if (memoized != null) {
        return memoized
    }

    val res = if (iterations == 0) {
        1
    } else if (stone == 0L) {
        sim(1, iterations - 1)
    } else if (stone.toString().length % 2 == 0) {
        val digits = stone.toString()
        val stone1 = digits.take(digits.length / 2).toLong()
        val stone2 = digits.drop(digits.length / 2).toLong()
        sim(stone1, iterations - 1) + sim(stone2, iterations - 1)
    } else {
        sim(stone * 2024, iterations - 1)
    }

    memo[key] = res
    return res
}