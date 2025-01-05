import kotlin.math.max

fun main() {
    val testInput = readInput("Day23_test").map { it.split("-") }
    val input = readInput("Day23").map { it.split("-") }

    println("Part 1 test: ${part1(testInput)}")
    println("Part 1: ${part1(input)}")
    println("Part 2 test: ${part2(testInput)}")
    println("Part 2: ${part2(input)}")
}

private fun part2(input: List<List<String>>): String {
    val clique = biggestClique(edges(input))
    return clique.sorted().joinToString(",")
}

private fun part1(input: List<List<String>>): Int {
    val edges = edges(input)

    val threes = mutableSetOf<List<String>>()
    for (k1 in edges.keys) {
        for (k2 in edges.keys) {
            if (k1 != k2 && edges[k1]!!.contains(k2)) {
                for (k3 in edges[k1]!!.intersect(edges[k2]!!)) {
                    threes.add(listOf(k1, k2, k3).sorted())
                }
            }
        }
    }

    return threes.count { it.any { k -> k.startsWith("t") } }
}

private fun edges(input: List<List<String>>): Map<String, Set<String>> {
    val edges = mutableMapOf<String, Set<String>>()
    for ((k1, k2) in input) {
        edges[k1] = (edges[k1] ?: emptySet()) + setOf(k2)
        edges[k2] = (edges[k2] ?: emptySet()) + setOf(k1)
    }

    return edges
}

private fun biggestClique(edges: Map<String, Set<String>>): Set<String> {
    val visited = mutableSetOf<Set<String>>()
    val queue = ArrayDeque<Set<String>>()
    var best = 0
    var bestClique = emptySet<String>()

    for (v in edges.keys) {
        queue.add(setOf(v))
    }

    while (!queue.isEmpty()) {
        val candidate = queue.removeFirst()
        val extensions = candidate.map { edges[it]!! }.reduce { x, y -> x.intersect(y) }

        if (extensions.isEmpty()) {
            if (candidate.size > best) {
                best = candidate.size
                bestClique = candidate
            }
        } else if (candidate.size + extensions.size > best) {
            for (e in extensions) {
                val next = candidate + setOf(e)
                if (!visited.contains(next)) {
                    visited.add(next)
                    queue.add(next)
                }
            }
        }
    }

    return bestClique
}