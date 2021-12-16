import sequtils
import strutils
import parseutils
import bitops
import sets
import tables
import options
import deques
import std/heapQueue

type Point = tuple[x: int, y: int, tile: int]

let input = stdin.readAll.strip.split("\n").mapIt(it.mapIt(int(it) - int('0')))

var queue = [(cost: 0, pos: (0, 0, 0))].toHeapQueue

var visited = initHashSet[Point]()

while queue[0].pos != (input.high, input[0].high, 8):
  let next = queue.pop()
  if not visited.contains(next.pos):
    visited.incl(next.pos)
    let (x, y, tile) = next.pos

    for neigh in @[(x: x + 1, y: y), (x, y + 1), (x - 1, y), (x, y - 1)]:
      if neigh.x >= 0 and neigh.y >= 0:
        let n_tile =
          if neigh.x > input.high or neigh.y > input[0].high:
            tile + 1
          else:
            tile
        let n_cost = next.cost + ((input[neigh.x mod input.len][neigh.y mod input[0].len] + n_tile - 1) mod 9 + 1)
        queue.push((n_cost, (neigh.x mod input.len, neigh.y mod input[0].len, n_tile)))

echo queue[0].cost
