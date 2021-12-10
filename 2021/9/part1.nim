import sequtils
import strutils
import parseutils
import bitops
import sets
import tables

proc lowPoint(key: tuple[x: int, y: int], map: Table[tuple[x: int, y: int], char]): bool =
  let x = key.x
  let y = key.y

  for neighbour in @[(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]:
    if map.hasKey(neighbour) and map[neighbour] <= map[key]:
      return false
  return true

let data = stdin.readAll.strip().split("\n").mapIt(toSeq(it))
var map = initTable[tuple[x: int, y: int], char]()

for x in data.low .. data.high:
  for y in data[x].low .. data[x].high:
    map[(x, y)] = data[x][y]

var riskSum = 0
for key in map.keys:
  if lowPoint(key, map):
    riskSum += 1 + int(map[key]) - int('0')

echo riskSum
