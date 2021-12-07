import sequtils
import strutils
import parseutils
import bitops
import sets
import tables

proc parseLine(line: string): tuple[x1: int, y1: int, x2: int, y2: int] =
  let ends = line.split(" -> ")
  return (
    ends[0].split(",")[0].parseInt,
    ends[0].split(",")[1].parseInt,
    ends[1].split(",")[0].parseInt,
    ends[1].split(",")[1].parseInt
  )

let vents = stdin.readAll().strip().split("\n").map(parseLine)
var spots = initCountTable[tuple[x: int, y: int]]()

for vent in vents:
  if vent.x1 == vent.x2:
    for y in min(vent.y1, vent.y2) .. max(vent.y1, vent.y2):
      spots.inc((vent.x1, y))
  elif vent.y1 == vent.y2:
    for x in min(vent.x1, vent.x2) .. max(vent.x1, vent.x2):
      spots.inc((x, vent.y1))
  elif abs(vent.x1 - vent.x2) == abs(vent.y1 - vent.y2):
    let left = min((x: vent.x1, y: vent.y1), (x: vent.x2, y: vent.y2))
    let right = max((x: vent.x1, y: vent.y1), (x: vent.x2, y: vent.y2))

    if left.y < right.y:
      for x in left.x .. right.x:
        spots.inc((x, left.y - left.x + x))
    else:
      for x in left.x .. right.x:
        spots.inc((x, left.y + left.x + x))


echo spots.values.toSeq.filterIt(it > 1).len
