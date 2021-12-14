import sequtils
import strutils
import parseutils
import bitops
import sets
import tables
import options

type point = tuple[x: int, y: int]

proc flip(point: point, over: point): point =
  if over.x != 0 and point.x < over.x:
    point
  elif over.y != 0 and point.y < over.y:
    point
  elif over.x != 0:
    (point.x - 2 * (point.x - over.x), point.y)
  else:
    (point.x, point.y - 2 * (point.y - over.y))

proc flip(points: HashSet[point], over: point): HashSet[point] =
  for point in points:
    result.incl(flip(point, over))

let input = stdin.readAll.strip.split("\n\n")

var points = input[0].split("\n").mapIt(it.split(",")).mapIt((x: it[0].parseInt, y: it[1].parseInt)).toHashSet

let folds = input[1].split("\n").mapIt(it.split(" ")[2].split("=")).mapIt(
  if it[0] == "x":
    (it[1].parseInt, 0)
  else:
    (0, it[1].parseInt)
)

for fold in folds:
  points = flip(points, fold)

for y in 0 .. points.mapIt(it.y).max:
  for x in 0 .. points.mapIt(it.x).max:
    if points.contains((x, y)):
      write(stdout, '#')
    else:
      write(stdout, '.')
  write(stdout, '\n')
