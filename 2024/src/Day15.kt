import kotlin.io.path.Path
import kotlin.io.path.readText

data class Robot(val map: Map<Position, Char>, val moves: List<Position>)

fun main() {
    val testInput = Path("src/Day15_test.txt").readText().trim().let { parseInput(it) }
    val input = Path("src/Day15.txt").readText().trim().let { parseInput(it) }

    println("Part 1 test: ${part1(testInput)}")
    println("Part 1: ${part1(input)}")
    println("Part 2 test: ${part2(testInput)}")
    println("Part 2: ${part2(input)}")
}

private fun part2(input: Robot): Long {
    val map = input.map.flatMap { (k, v) ->
        when (v) {
            '#' -> listOf(Pair(Position(k.x, k.y * 2), v), Pair(Position(k.x, k.y * 2 + 1), v))
            else -> listOf(Pair(Position(k.x, k.y * 2), v))
        }
    }.toMap().toMutableMap()
    var pos = map.keys.find { map[it] == '@' }!!
    map.remove(pos)

    for (m in input.moves) {
        val pushes = pushed(map, pos, m, emptySet<Position>().toMutableSet()).toSet()

        if (pushes.any { map[it] == '#' }) {
            continue
        } else {
            pos = pos.add(m)
            pushes.forEach { map.remove(it) }
            pushes.forEach { map[it.add(m)] = 'O' }
        }
    }

    return map.keys.filter { map[it] == 'O' }.sumOf { it.x.toLong() * 100 + it.y }
}

private fun pushed(map: Map<Position, Char>, pos: Position, dir: Position, visited: MutableSet<Position>): Sequence<Position> {
    if (visited.contains(pos)) {
        return sequence {}
    } else {
        visited.add(pos)
    }

    return sequence {
        val up = pos.add(dir)
        val left = pos.add(dir).add(Position(0, -1))
        if (dir.x == 0) {
            val next = pos.add(dir)

            if (map[next] == '#') {
                yield(next)
            } else if (dir.y == -1 && map[next.add(dir)] == 'O') {
                yield(next.add(dir))
                yieldAll(pushed(map, next.add(dir), dir, visited))
            } else if (map[next] == 'O') {
                yield(next)
                yieldAll(pushed(map, next.add(dir), dir, visited))
            }
        } else if (map[up] == '#') {
            yield(up)
        } else if (map[up] == 'O') {
            yield(up)
            yieldAll(pushed(map, up, dir, visited))
            yieldAll(pushed(map, up.add(Position(0, 1)), dir, visited))
        } else if (map[left] == 'O') {
            yield(left)
            yieldAll(pushed(map, left, dir, visited))
            yieldAll(pushed(map, up, dir, visited))
        }
    }
}

private fun part1(input: Robot): Long {
    val map = input.map.toMutableMap()
    var pos = map.keys.find { map[it] == '@' }!!
    map.remove(pos)

    for (m in input.moves) {
        val next = pos.add(m)
        var end = next
        while (map.contains(end) && map[end] != '#') {
            end = end.add(m)
        }

        if (map[end] == '#') {
            continue
        } else if (next == end) {
            pos = next
        } else {
            map[end] = 'O'
            map.remove(next)
            pos = next
        }
    }

    return map.filter { (_, v) -> v == 'O' }.keys.sumOf { (x, y) -> 100 * x.toLong() + y }
}

private fun parseInput(input: String): Robot {
    val (unparsedMap, unparsedMoves) = input.split("\n\n")

    val map = sequence {
        val rows = unparsedMap.split("\n")
        for (i in rows.indices) {
            for (j in rows[i].indices) {
                if (rows[i][j] != '.') {
                    yield(Pair(Position(i, j), rows[i][j]))
                }
            }
        }
    }.toMap()

    val moves = unparsedMoves.replace("\n", "").map {
        when (it) {
            '<' -> Position(0, -1)
            '>' -> Position(0, 1)
            '^' -> Position(-1, 0)
            'v' -> Position(1, 0)
            else -> throw Exception("Should not happen")
        }
    }

    return Robot(map, moves)
}
