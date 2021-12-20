import sequtils
import strutils
import parseutils
import bitops
import sets
import tables
import options
import deques
import std/heapQueue
import std/strformat
import algorithm
import sugar

type Point = tuple[x: int, y: int, z: int]
type Rot = tuple[x: int, y: int, z: int, xs: int, ys: int, zs: int]
type Transform = tuple[rot: Rot, translation: Point]

proc parseScanner(list: string): seq[Point] =
  return list.split("\n")[1..^1].mapIt(it.split(",").map(parseInt)).mapIt((it[0], it[1], it[2]))

proc distances(scanner: seq[Point]): seq[HashSet[int]] =
  for x in scanner:
    result.add(initHashSet[int]())
    for y in scanner:
      if x != y:
        result[^1].incl(abs(x[0] - y[0]) + abs(x[1] - y[1]) + abs(x[2] - y[2]))

proc match(dists1: seq[HashSet[int]], dists2: seq[HashSet[int]]): Table[int, int] =
  for i, x in dists1:
    let best = dists2.mapIt(x.intersection(it).len)
    if best[best.maxIndex] >= 7:
      result[i] = best.maxIndex

iterator rotations(): Rot =
  for x in 0..2:
    for y in 0..2:
      for z in 0..2:
        for xs in 0..1:
          for ys in 0..1:
            for zs in 0..1:
              yield (x, y, z, xs, ys, zs)

proc get(point: Point, coord: int): int =
  if coord == 0: return point.x
  elif coord == 1: return point.y
  else: return point.z

proc rotate(point: Point, rot: Rot): Point =
  return (
    x: if rot.xs == 0: get(point, rot.x) else: -get(point, rot.x),
    y: if rot.ys == 0: get(point, rot.y) else: -get(point, rot.y),
    z: if rot.zs == 0: get(point, rot.z) else: -get(point, rot.z),
  )

proc diff(p1: Point, p2: Point): Point =
  return (p1.x - p2.x, p1.y - p2.y, p1.z - p2.z)

proc add(p1: Point, p2: Point) : Point =
  return (p1.x + p2.x, p1.y + p2.y, p1.z + p2.z)

proc align(scanner1: seq[Point], scanner2: seq[Point], match: Table[int, int]): Transform =
  for rot in rotations():
    var left = newSeq[Point]()
    var right = newSeq[Point]()
    for k, v in match:
      left.add(scanner1[k])
      right.add(rotate(scanner2[v], rot))
    let translation = diff(left[0], right[0])
    if right.mapIt(it.add(translation)) == left:
      return (rot, translation)

proc apply(point: Point, trans: Transform): Point =
  point.rotate(trans.rot).add(trans.translation)

let scanners = stdin.readAll.strip.split("\n\n").map(parseScanner)
let dists = scanners.map(distances)

var mappings = initTable[tuple[a: int, b: int], Transform]()
for i, x in dists:
  for j, y in dists:
    if j != i:
      let m = match(x, y)
      if m.len >= 12:
        mappings[(i, j)] = align(scanners[i], scanners[j], m)

var goto = initTable[int, int]()
var q = initDeque[tuple[a: int, b: int]]()
var visited = initHashSet[int]()
q.addFirst((0, 0))
while q.len > 0:
  let (next, from_node) = q.popFirst()
  if not visited.contains(next):
    goto[next] = from_node
    visited.incl(next)
    for e, m in mappings:
      if e.a == next:
        q.addFirst((e.b, next))

let positions = collect:
  for i, scanner in scanners:
    var coords = i
    var point = (0, 0, 0)
    while coords != 0:
      point = point.apply(mappings[(goto[coords], coords)])
      coords = goto[coords]
    point

let scanner_dists = collect:
  for x in positions:
    for y in positions:
      abs(x[0] - y[0]) + abs(x[1] - y[1]) + abs(x[2] - y[2])

echo scanner_dists[scanner_dists.maxIndex]
