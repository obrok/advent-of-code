import java.util.*
import kotlin.collections.ArrayDeque

data class Maze(val start: Position, val end: Position, val walls: Set<Position>)
data class QueueItem(val score: Int, val pos: Position, val dir: Position, val from: Pair<Position, Position>)

fun main() {
    val testInput = parseInput(readInput("Day16_test"))
    val input = parseInput(readInput("Day16"))

    println("Part 1 test: ${part1(testInput)}")
    println("Part 1: ${part1(input)}")
    println("Part 2 test: ${part2(testInput)}")
    println("Part 2: ${part2(input)}")
}

private fun part1(maze: Maze): Int {
    val (scores, _) = explore(maze)
    return scores.filter { it.key.first == maze.end }.values.min()
}

private fun part2(maze: Maze): Int {
    val (scores, from) = explore(maze)
    val queue = ArrayDeque<Pair<Position, Position>>()
    val visited = emptySet<Position>().toMutableSet()
    val bestScore = scores.filter { it.key.first == maze.end }.values.min()

    for (x in from.keys.filter { it.first == maze.end && scores[it] == bestScore }) {
        queue.add(x)
    }

    while (queue.isNotEmpty()) {
        val pos = queue.removeFirst()
        visited.add(pos.first)

        if (pos != Pair(maze.start, Position(0, 1))) {
            for (next in from[pos]!!) {
                queue.add(next)
            }
        }
    }

    return visited.size
}

private fun explore(maze: Maze): Pair<Map<Pair<Position, Position>, Int>, Map<Pair<Position, Position>, Set<Pair<Position, Position>>>> {
    val queue = PriorityQueue(compareBy(QueueItem::score))
    queue.add(QueueItem(0, maze.start, Position(0, 1), Pair(maze.start, Position(0, -1))))
    val visited = emptySet<Pair<Position, Position>>().toMutableSet()
    val scores = emptyMap<Pair<Position, Position>, Int>().toMutableMap()
    val froms = emptyMap<Pair<Position, Position>, Set<Pair<Position, Position>>>().toMutableMap()

    while (queue.isNotEmpty()) {
        val (score, pos, dir, from) = queue.poll()
        val posdir = Pair(pos, dir)

        if (!scores.contains(posdir)) {
            scores[posdir] = score
        }

        if (score <= scores[posdir]!!) {
            froms[posdir] = (froms[posdir] ?: emptySet()).plus(from)
        }

        if (visited.contains(Pair(pos, dir))) {
            continue
        }

        visited.add(Pair(pos, dir))

        for (turn in listOf(dir.turnRight(), dir.turnLeft())) {
            queue.add(QueueItem(score + 1000, pos, turn, posdir))
        }

        val move = pos.add(dir)
        if (!maze.walls.contains(move)) {
            queue.add(QueueItem(score + 1, move, dir, posdir))
        }
    }

    return Pair(scores, froms)
}
private fun parseInput(input: List<String>): Maze {
    var start = Position(0, 0)
    var end = Position(0, 0)
    val walls = emptySet<Position>().toMutableSet()

    for (x in input.indices) {
        for (y in input[x].indices) {
            when (input[x][y]) {
                '#' -> walls.add(Position(x, y))
                'S' -> start = Position(x, y)
                'E' -> end = Position(x, y)
                else -> {}
            }
        }
    }

    return Maze(start, end, walls)
}