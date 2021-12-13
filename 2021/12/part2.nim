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

var paths = @[(double: false, path: @["start"])]
var count = 0
while paths.len > 0:
  let previous = paths.pop
  for next in edges[previous.path[previous.path.high]]:
    let extended = previous.path.concat(@[next])
    if next == "end":
      count += 1
    elif next != "start" and next.small:
      if not previous.path.contains(next):
        paths.add((double: previous.double, path: extended))
      elif not previous.double:
        paths.add((double: true, path: extended))
    elif not next.small:
      paths.add((double: previous.double, path: extended))

echo count
