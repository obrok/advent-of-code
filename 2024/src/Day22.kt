fun main() {
    val testInput = readInput("Day22_test").map { it.toInt() }
    val input = readInput("Day22").map { it.toInt() }

    println("Part 1 test: ${part1(testInput)}")
    println("Part 1: ${part1(input)}")
    println("Part 2 test: ${part2(testInput)}")
    println("Part 2: ${part2(input)}")
}

private fun part1(input: List<Int>): Long {
    return input.sumOf { prices(it.toLong()).last() }
}

private fun part2(input: List<Int>): Long {
    val sums = mutableMapOf<List<Long>, Long>()

    for (prices in input.map { prices(it.toLong()).map { p -> p % 10 } }) {
        val seen = mutableSetOf<List<Long>>()
        for (i in prices.indices.take(prices.size - 4)) {
            val seq = listOf(
                prices[i + 1] - prices[i],
                prices[i + 2] - prices[i + 1],
                prices[i + 3] - prices[i + 2],
                prices[i + 4] - prices[i + 3])

            if (!seen.contains(seq)) {
                val price = prices[i + 4]
                seen.add(seq)
                sums[seq] = (sums[seq] ?: 0) + price
            }
        }
    }

    return sums.values.max()
}

const val MOD = (1 shl 24).toLong()

private fun prices(n: Long): List<Long> {
    var x = n
    return (0..2000).map {
        val res = x
        x = step(x)
        res
    }
}

private fun step(n: Long): Long {
    var x = n xor (n * 64) % MOD
    x = x xor (x / 32) % MOD
    return x xor (x * 2048) % MOD
}