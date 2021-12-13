import sequtils
import strutils
import parseutils
import bitops
import sets
import tables
import options

proc small(cave: string): bool =
  return cave.toLowerAscii == cave

var edges = initTable[string, seq[string]]()
for line in stdin.readAll.strip.split("\n"):
  let edge = line.split("-")
  if not edges.hasKey(edge[0]):
    edges[edge[0]] = @[]
  edges[edge[0]].add(edge[1])
  if not edges.hasKey(edge[1]):
    edges[edge[1]] = @[]
  edges[edge[1]].add(edge[0])

var paths = @[@["start"]]
var count = 0
while paths.len > 0:
  let path = paths.pop
  for next in edges[path[path.high]]:
    let extended = path.concat(@[next])
    if next == "end":
      count += 1
    elif next.small:
      if not path.contains(next):
        paths.add(extended)
    else:
      paths.add(extended)

echo count
