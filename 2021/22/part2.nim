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

type Range = tuple[lo: int, hi: int]
type Step = tuple[on: bool, x: Range, y: Range, z: Range]
type Point = tuple[x: int, y: int, z: int]
type Cube = tuple[x: Range, y: Range, z: Range]

type Node = ref object
  bounds: Cube
  on: bool
  le: Node
  ri: Node

proc min_max(data: seq[Range]): Range =
  let mins = data.mapIt(it.lo)
  let maxs = data.mapIt(it.hi)
  (mins[mins.minIndex], maxs[maxs.maxIndex])

proc print(node: Node, indent: int): string =
  if node.le != nil:
    "$3{on: $2, bounds: $1}\n$4" % [$node.bounds, $node.on, repeat(' ', indent), [node.le, node.ri].mapIt(it.print(indent + 1)).join("\n")]
  else:
    "$3{on: $2, bounds: $1}" % [$node.bounds, $node.on, repeat(' ', indent)]

proc print(node: Node): string = print(node, 0)

proc limit(r1: Range, r2: Range): Range =
  (max(r1.lo, r2.lo), min(r1.hi, r2.hi))

proc limit(cube1: Cube, cube2: Cube): Cube =
  (limit(cube1.x, cube2.x), limit(cube1.y, cube2.y), limit(cube1.z, cube2.z))

proc empty(r: Range): bool =
  r.lo > r.hi

proc empty(cube: Cube): bool =
  cube.x.empty or cube.y.empty or cube.z.empty

proc apply(node: var Node, cube: Cube, on: bool) =
  if node.le != nil:
    apply(node.le, cube.limit(node.le.bounds), on)
    apply(node.ri, cube.limit(node.ri.bounds), on)
  elif cube.empty:
    discard
  elif cube == node.bounds:
    node.on = on
  elif node.bounds.x.lo != cube.x.lo:
    node.le = Node(on: node.on, bounds: ((node.bounds.x.lo, cube.x.lo - 1), node.bounds.y, node.bounds.z))
    node.ri = Node(on: node.on, bounds: ((cube.x.lo, node.bounds.x.hi), node.bounds.y, node.bounds.z))
    apply(node.ri, cube, on)
  elif node.bounds.y.lo != cube.y.lo:
    node.le = Node(on: node.on, bounds: (node.bounds.x, (node.bounds.y.lo, cube.y.lo - 1), node.bounds.z))
    node.ri = Node(on: node.on, bounds: (node.bounds.x, (cube.y.lo, node.bounds.y.hi), node.bounds.z))
    apply(node.ri, cube, on)
  elif node.bounds.z.lo != cube.z.lo:
    node.le = Node(on: node.on, bounds: (node.bounds.x, node.bounds.y, (node.bounds.z.lo, cube.z.lo - 1)))
    node.ri = Node(on: node.on, bounds: (node.bounds.x, node.bounds.y, (cube.z.lo, node.bounds.z.hi)))
    apply(node.ri, cube, on)
  elif node.bounds.x.hi != cube.x.hi:
    node.le = Node(on: node.on, bounds: ((node.bounds.x.lo, cube.x.hi), node.bounds.y, node.bounds.z))
    node.ri = Node(on: node.on, bounds: ((cube.x.hi + 1, node.bounds.x.hi), node.bounds.y, node.bounds.z))
    apply(node.le, cube, on)
  elif node.bounds.y.hi != cube.y.hi:
    node.le = Node(on: node.on, bounds: (node.bounds.x, (node.bounds.y.lo, cube.y.hi), node.bounds.z))
    node.ri = Node(on: node.on, bounds: (node.bounds.x, (cube.y.hi + 1, node.bounds.y.hi), node.bounds.z))
    apply(node.le, cube, on)
  elif node.bounds.z.hi != cube.z.hi:
    node.le = Node(on: node.on, bounds: (node.bounds.x, node.bounds.y, (node.bounds.z.lo, cube.z.hi)))
    node.ri = Node(on: node.on, bounds: (node.bounds.x, node.bounds.y, (cube.z.hi + 1, node.bounds.z.hi)))
    apply(node.le, cube, on)
  else:
    assert false

proc count(node: Node): int =
  if node.le != nil:
    count(node.le) + count(node.ri)
  elif node.on:
    let b = node.bounds
    assert b.x.hi >= b.x.lo
    assert b.y.hi >= b.y.lo
    assert b.z.hi >= b.z.lo
    (b.x.hi - b.x.lo + 1) * (b.y.hi - b.y.lo + 1) * (b.z.hi - b.z.lo + 1)
  else:
    0

let steps = collect:
  for line in stdin.readAll.strip.split("\n"):
    let parts = line.split(" ")
    let coords = parts[1].split(",").map(
      x => (
        let pair = x.split("=")[1].split("..").mapIt(it.parseInt)
        (lo: pair[0], hi: pair[1])
      )
    )

    (on: if parts[0] == "on": true else: false, x: coords[0], y: coords[1], z: coords[2])

let x_bounds = steps.mapIt(it.x).min_max()
let y_bounds = steps.mapIt(it.y).min_max()
let z_bounds = steps.mapIt(it.z).min_max()

var data = Node(bounds: (x_bounds, y_bounds, z_bounds))
for step in steps:
  apply(data, (step.x, step.y, step.z), step.on)

echo count(data)
