import kotlin.io.path.Path
import kotlin.io.path.readText

enum class GateKind {
    AND {
        override fun eval(left: Boolean, right: Boolean): Boolean {
            return left && right
        }
    },
    OR {
        override fun eval(left: Boolean, right: Boolean): Boolean {
            return left || right
        }
    },
    XOR {
        override fun eval(left: Boolean, right: Boolean): Boolean {
            return left != right
        }
    };

    abstract fun eval(left: Boolean, right: Boolean): Boolean
}
data class Gate(val left: String, val right: String, val out: String, val kind: GateKind)
data class Gates(val initial: Map<String, Boolean>, val gates: Map<String, Gate>)

fun main() {
    val testInput = parseInput(Path("src/Day24_test.txt").readText())
    val input = parseInput(Path("src/Day24.txt").readText())

    println("Part 1 test: ${part1(testInput)}")
    println("Part 1: ${part1(input)}")
    println("Part 2: ${part2(input)}")
}

private fun part1(input: Gates): Long {
    val memo = computeCircuit(input)
    return gatesToNumber(memo!!, "z")
}

private fun computeCircuit(input: Gates): Map<String, Boolean>? {
    val memo = input.initial.toMutableMap()
    for (w in input.gates.keys) {
        if (computeWire(input, memo, w) == null) {
            return null
        }
    }

    return memo
}

private fun gatesToNumber(memo: Map<String, Boolean>, prefix: String): Long {
    return memo.keys.filter { it.startsWith(prefix) }.sorted().joinToString("") {
        if (memo[it]!!) { "1" } else { "0" }
    }.reversed().toLong(2)
}

fun Int.fmt(): String {
    return this.toString().padStart(2, '0')
}

private fun part2(orig1: Gates): String {
//    var orig = orig1
//    orig = swap(orig, orig.gates["z07"]!!, orig.gates["rts"]!!)
//    orig = swap(orig, orig.gates["z12"]!!, orig.gates["jpj"]!!)
//    orig = swap(orig, orig.gates["kgj"]!!, orig.gates["z26"]!!)
//    orig = swap(orig, orig.gates["chv"]!!, orig.gates["vvw"]!!)
//
//    val a0 = orig.gates.values.find {
//        it.kind == GateKind.XOR && setOf(it.left, it.right) == setOf("x00", "y00")
//    }
//    var c = orig.gates.values.find {
//        it.kind == GateKind.AND && setOf(it.left, it.right) == setOf("x00", "y00")
//    }
//
//    for (i in 1..44) {
//        println()
//        println(i)
//        val a = orig.gates.values.find {
//            it.kind == GateKind.XOR && setOf(it.left, it.right) == setOf("x${i.fmt()}", "y${i.fmt()}")
//        }
//        println("A: $a")
//        val b = orig.gates.values.find {
//            it.kind == GateKind.AND && setOf(it.left, it.right) == setOf("x${i.fmt()}", "y${i.fmt()}")
//        }
//        println("B: $b")
//        val z = orig.gates.values.find {
//            it.kind == GateKind.XOR && setOf(it.left, it.right) == setOf(c!!.out, a!!.out)
//        }
//        println("Z: $z")
//        val d = orig.gates.values.find {
//            it.kind == GateKind.AND && setOf(it.left, it.right) == setOf(a!!.out, c!!.out)
//        }
//        println("D: $d")
//        c = orig.gates.values.find {
//            it.kind == GateKind.OR && setOf(it.left, it.right) == setOf(b!!.out, d!!.out)
//        }
//        println("C: $c")
//    }

    return listOf(
        "z07","rts",
        "z12","jpj",
        "kgj","z26",
        "chv","vvw"
    ).sorted().joinToString(",")
}

private fun swap(input: Gates, a: Gate, b: Gate): Gates {
    fun swapper(input: String): String {
        return if (input == a.out) {
            b.out
        } else if (input == b.out) {
            a.out
        } else {
            input
        }
    }

    val gates = input.gates.values.map {
        it.copy(
            out = swapper(it.out)
        )
    }.associateBy { it.out }
    return input.copy(gates = gates)
}

private fun computeWire(gates: Gates, memo: MutableMap<String, Boolean>, wire: String, path: Set<String> = emptySet()): Boolean? {
    if (path.contains(wire)) {
        return null
    }

    if (memo[wire] == null) {
        val gate = gates.gates[wire]!!
        val path2 = path + setOf(wire)
        val left = computeWire(gates, memo, gate.left, path2)
        val right = computeWire(gates, memo, gate.right, path2)
        if (left != null && right != null) {
            memo[wire] = gate.kind.eval(left, right)
        } else {
            return null
        }
    }

    return memo[wire]!!
}

private fun parseInput(input: String): Gates {
    val (initialText, gatesText) = input.trim().split("\n\n")
    val initial = initialText.lines().associate {
        val (name, value) = it.split(": ")
        if (value == "1") {
            name to true
        } else {
            name to false
        }
    }

    val gates = gatesText.lines().associate {
        val (inp, out) = it.split(" -> ")
        val (left, op, right) = inp.split(" ")
        val kind = when (op) {
            "AND" -> GateKind.AND
            "OR" -> GateKind.OR
            else -> GateKind.XOR
        }

        out to Gate(left, right, out, kind)
    }

    return Gates(initial, gates)
}
