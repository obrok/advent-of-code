
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

var data = initHashSet[Point]()

for step in steps:
  for x in step.x.lo .. step.x.hi:
    for y in step.y.lo .. step.y.hi:
      for z in step.z.lo .. step.z.hi:
        if step.on:
          data.incl((x, y, z))
        else:
          data.excl((x, y, z))

echo data.len
