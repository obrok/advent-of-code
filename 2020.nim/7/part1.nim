import strutils
import sequtils
import tables
import strscans
import sets

proc parseLine(line: string): seq[(string, string)] =
  let parts = line.split(" bags contain ")
  parts[1].strip(chars = {'.'}).split(", ").map(proc(x: string): (string, string) =
    var count: int
    var bag: string
    discard scanf(x, "$i $+ bag", count, bag)
    (bag.strip(leading=false, chars={'s'}), parts[0]))

var parent = initTable[string, seq[string]]()

for line in stdin.readAll().strip().split("\n"):
  for (x, y) in parseLine(line):
    if not parent.hasKey(x):
      parent[x] = @[]
    parent[x].add(y)

proc parents(node: string): HashSet[string] =
  incl(result, node)
  if parent.hasKey(node):
    result = parent[node].map(parents).foldl(a + b, result)

echo parents("shiny gold").len - 1
