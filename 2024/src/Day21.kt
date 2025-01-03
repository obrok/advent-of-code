import kotlin.math.abs
import kotlin.math.sign

fun main() {
    val testInput = readInput("Day21_test")
    val input = readInput("Day21")

    println("Part 1 test: ${part1(testInput, 3)}")
    println("Part 1: ${part1(input, 3)}")
    println("Part 2: ${part1(testInput, 26)}")
    println("Part 2: ${part1(input, 26)}")
}

val keypad = keypadize("789|456|123| 0A")
val directional = keypadize(" ^A|<v>")

private fun part1(input: List<String>, levels: Int = 3): Long {
    return input.sumOf { line ->
        val l = directionLen(line, levels)
        val d = line.replace("A", "").toInt()
        l * d
    }
}

private fun transitions(keypad: Map<Char, Position>): Map<Pair<Char, Char>, List<String>> {
    return sequence {
        for (x in keypad.keys.filter { it != ' ' }) {
            yield((x to x) to listOf("A"))
        }

        for (x in keypad.keys.filter { it != ' ' }) {
            for (y in keypad.keys.filter { it != ' ' && it != x }) {
                val dif = keypad[y]!!.sub(keypad[x]!!)
                val steps = List(abs(dif.x)) { Position(dif.x.sign, 0) } + List(abs(dif.y)) { Position(0, dif.y.sign) }
                val perms = permutations(steps.indices.toSet()).map { it.map { i -> steps[i] } }
                val options = perms.toSet().filter { optSteps ->
                    var pos = keypad[x]!!
                    optSteps.all {
                        pos = pos.add(it)
                        keypad[' '] != pos
                    }
                }.map { optSteps ->
                    val dirs = optSteps.map {
                        when (it) {
                            Position(1, 0) -> 'v'
                            Position(-1, 0) -> '^'
                            Position(0, 1) -> '>'
                            else -> '<'
                        }
                    }.joinToString("")
                    "${dirs}A"
                }

                yield((x to y) to options)
            }
        }
    }.toMap()
}

private fun<A> permutations(items: Set<A>, perm: List<A> = listOf()): Sequence<List<A>> {
    return sequence {
        if (items.isEmpty()) {
            yield(perm)
        } else {
            for (i in items) {
                val perm2 = listOf(i) + perm
                val rest = items - setOf(i)
                yieldAll(permutations(rest, perm2))
            }
        }
    }
}

private val memo = mutableMapOf<Triple<String, Int, Boolean>, Long>()

private fun directionLen(seq: String, level: Int, initial: Boolean = true): Long {
    val key = Triple(seq, level, initial)

    if (memo[key] == null) {
        memo[key] = doDirectionLen(seq, level, initial)
    }

    return memo[key]!!
}

private fun doDirectionLen(seq: String, level: Int, initial: Boolean = true): Long {
    val keypad = if (initial) { keypad } else { directional }

    return if (level == 0) {
        seq.length.toLong()
    } else {
        "A$seq".zip(seq).sumOf { (from, to) ->
            keypad[from to to]!!.minOf {
                directionLen(it, level - 1, false)
            }.toLong()
        }
    }
}

private fun keypadize(str: String): Map<Pair<Char, Char>, List<String>> {
    val str2 = str.split("|")
    val positions = sequence {
        for (x in str2.indices) {
            for (y in str2[x].indices) {
                yield(str2[x][y] to Position(x, y))
            }
        }
    }.toMap()

    return transitions(positions)
}