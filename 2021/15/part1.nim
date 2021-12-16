import sequtils
import strutils
import parseutils
import bitops
import sets
import tables
import options
import deques
import std/heapQueue

type Point = tuple[x: int, y: int]

let input = stdin.readAll.strip.split("\n").mapIt(it.mapIt(int(it) - int('0')))

var queue = [(cost: 0, pos: (0, 0))].toHeapQueue

var visited = initHashSet[Point]()

while queue[0].pos != (input.high, input[0].high):
  let next = queue.pop()
  if not visited.contains(next.pos):
    visited.incl(next.pos)
    let (x, y) = next.pos

    for neigh in @[(x: x + 1, y: y), (x, y + 1), (x - 1, y), (x, y - 1)]:
      if (input.low..input.high).contains(neigh.x) and (input[0].low..input[0].high).contains(neigh.y):
        queue.push((next.cost + input[neigh.x][neigh.y], neigh))

echo queue[0].cost
