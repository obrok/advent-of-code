import sequtils
import strutils
import parseutils
import bitops
import sets
import tables
import options

type Point = tuple[x: int, y: int]

var octopi = stdin.readAll.strip.split("\n").mapIt(it.toSeq.mapIt(int(it) - int('0')))

proc flash(octopi: var seq[seq[int]], flashed: var HashSet[Point], x: int, y: int) =
  if not flashed.contains((x, y)) and octopi[x][y] >= 10:
    flashed.incl((x, y))

    for x2 in max(octopi.low, x - 1) .. min(octopi.high, x + 1):
      for y2 in max(octopi[0].low, y - 1) .. min(octopi[0].high, y + 1):
        if x2 != x or y2 != y:
          octopi[x2][y2] += 1 
          octopi.flash(flashed, x2, y2)

var step = 1
while true:
  var flashed = initHashSet[Point]()
  for x in octopi.low .. octopi.high:
    for y in octopi[0].low .. octopi[0].high:
      octopi[x][y] += 1
      octopi.flash(flashed, x, y)

  if octopi.allIt(it.allIt(it >= 10)):
    break

  for x in octopi.low .. octopi.high:
    for y in octopi[0].low .. octopi[0].high:
      if octopi[x][y] >= 10:
        octopi[x][y] = 0

  step += 1

echo step
