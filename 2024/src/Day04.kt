fun main() {
    val testInput = readInput("Day04_test")
    val input = readInput("Day04")

    println("Part 1 test: ${part1(testInput)}")
    println("Part 1: ${part1(input)}")
    println("Part 2 test: ${part2(testInput)}")
    println("Part 2: ${part2(input)}")
}

fun part1(input: List<String>): Int {
    return sequence {
        for (i in input.indices) {
            for (j in input[i].indices) {
                yield(countXmas1(input, i, j))
            }
        }
    }.sum()
}

fun part2(input: List<String>): Int {
    return sequence {
        for (i in 1..(input.count() - 2)) {
            for (j in 1..(input[0].length - 2)) {
                yield(Pair(i, j))
            }
        }
    }.count { (i, j) ->
        val sm1 = listOf(input[i + 1][j + 1], input[i - 1][j - 1])
        val sm2 = listOf(input[i - 1][j + 1], input[i + 1][j - 1])
        input[i][j] == 'A' && sm1.sorted() == listOf('M', 'S') && sm2.sorted() == listOf('M', 'S')
    }
}

fun countXmas1(input: List<String>, i: Int, j: Int): Int {
    return sequence {
        for (di in -1..1){
            for (dj in -1..1) {
                for (it in "XMAS".indices) {
                    val newI = i + it * di
                    val newJ = j + it * dj

                    if (newI !in input.indices || newJ !in input[0].indices || input[newI][newJ] != "XMAS"[it]) {
                        break
                    }

                    if (it == "XMAS".length - 1) {
                        yield(1)
                    }
                }
            }
        }
    }.sum()
}