import sequtils
import strutils
import parseutils
import bitops
import sets
import tables
import algorithm

proc neighbours(key: tuple[x: int, y: int]): seq[tuple[x: int, y: int]] =
  let x = key.x
  let y = key.y
  return @[(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]

proc lowPoint(key: tuple[x: int, y: int], map: Table[tuple[x: int, y: int], char]): bool =
  for neighbour in neighbours(key):
    if map.hasKey(neighbour) and map[neighbour] <= map[key]:
      return false
  return true

proc basinSize(key: tuple[x: int, y: int], map: Table[tuple[x: int, y: int], char]): int =
  var visited = initSet[tuple[x: int, y: int]]()
  var queue = @[key]

  while queue.len > 0:
    let next = queue.pop
    if map.hasKey(next) and map[next] != '9':
      visited.incl(next)

      for neigh in neighbours(next):
        if not visited.contains(neigh):
          queue.add(neigh)

  return visited.len

let data = stdin.readAll.strip().split("\n").mapIt(toSeq(it))
var map = initTable[tuple[x: int, y: int], char]()

for x in data.low .. data.high:
  for y in data[x].low .. data[x].high:
    map[(x, y)] = data[x][y]

var basins = newSeq[int]()
for key in map.keys:
  if lowPoint(key, map):
    basins.add(basinSize(key, map))

sort(basins, order = SortOrder.Descending)
echo basins[0] * basins[1] * basins[2]
